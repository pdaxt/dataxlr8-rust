#!/usr/bin/env python3
"""
Universal E2E test harness for dataxlr8 MCP servers.

Schema-driven: discovers tools from tools/list, auto-generates edge case tests
from each tool's input_schema, runs them, reports pass/fail.

Usage:
    python e2e_harness.py <binary_path>
    python e2e_harness.py <binary_path> --json          # JSON report to stdout
    python e2e_harness.py <binary_path> --report <path>  # JSON report to file
"""
import json
import os
import subprocess
import sys
import time
import uuid

DB_URL = os.environ.get("DATABASE_URL", "postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8")
TIMEOUT_INIT = 10
TIMEOUT_CALL = 10
TEST_PREFIX = "e2e_test_"
SQL_INJECTION = "'; DROP TABLE x; --"
OVERSIZED = "A" * 50_001


class McpClient:
    """JSON-RPC client for MCP servers over stdio."""

    def __init__(self, binary_path):
        self.binary_path = binary_path
        self.name = os.path.basename(binary_path)
        self.proc = None
        self._next_id = 1

    def start(self):
        self.proc = subprocess.Popen(
            ["env", f"DATABASE_URL={DB_URL}", "RUST_LOG=error", self.binary_path],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )

    def stop(self):
        if self.proc:
            try:
                self.proc.stdin.close()
            except:
                pass
            try:
                self.proc.kill()
                self.proc.wait(timeout=3)
            except:
                pass

    def _send(self, msg):
        data = json.dumps(msg) + "\n"
        self.proc.stdin.write(data.encode())
        self.proc.stdin.flush()

    def _recv(self, timeout=TIMEOUT_CALL):
        import select
        ready, _, _ = select.select([self.proc.stdout], [], [], timeout)
        if not ready:
            return None
        line = self.proc.stdout.readline().decode().strip()
        if not line:
            return None
        return json.loads(line)

    def _next_request_id(self):
        rid = self._next_id
        self._next_id += 1
        return rid

    def initialize(self):
        self._send({
            "jsonrpc": "2.0", "id": self._next_request_id(),
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {"name": "e2e_harness", "version": "1.0"}
            }
        })
        resp = self._recv(TIMEOUT_INIT)
        if not resp or "error" in resp:
            raise RuntimeError(f"Init failed: {resp}")

        # Send initialized notification
        self._send({"jsonrpc": "2.0", "method": "notifications/initialized"})
        time.sleep(0.2)
        return resp

    def list_tools(self):
        self._send({
            "jsonrpc": "2.0", "id": self._next_request_id(),
            "method": "tools/list", "params": {}
        })
        resp = self._recv()
        if not resp:
            raise RuntimeError("tools/list timeout")
        return resp.get("result", {}).get("tools", [])

    def call_tool(self, name, arguments=None):
        self._send({
            "jsonrpc": "2.0", "id": self._next_request_id(),
            "method": "tools/call",
            "params": {"name": name, "arguments": arguments or {}}
        })
        resp = self._recv()
        return resp


def extract_schema_info(tool):
    """Extract param info from a tool's input_schema."""
    schema = tool.get("inputSchema") or tool.get("input_schema") or {}
    properties = schema.get("properties", {})
    required = set(schema.get("required", []))

    params = []
    for name, spec in properties.items():
        params.append({
            "name": name,
            "type": spec.get("type", "string"),
            "required": name in required,
            "enum": spec.get("enum"),
            "description": spec.get("description", ""),
        })
    return params


def generate_valid_value(param):
    """Generate a valid test value for a parameter based on its type."""
    ptype = param["type"]
    pname = param["name"]

    if param.get("enum"):
        return param["enum"][0]

    if ptype == "string":
        if "email" in pname:
            return f"{TEST_PREFIX}{uuid.uuid4().hex[:8]}@test.dataxlr8.com"
        if "id" in pname.lower() or pname == "id":
            return str(uuid.uuid4())
        if "url" in pname:
            return "https://example.com/test"
        if "query" in pname:
            return "test search query"
        return f"{TEST_PREFIX}{pname}_{uuid.uuid4().hex[:6]}"

    if ptype == "integer":
        if "limit" in pname:
            return 10
        if "offset" in pname:
            return 0
        return 1

    if ptype == "number":
        if "rate" in pname:
            return 0.15
        if "amount" in pname or "value" in pname:
            return 100.0
        return 1.0

    if ptype == "boolean":
        return True

    if ptype == "array":
        return [f"{TEST_PREFIX}tag1"]

    if ptype == "object":
        return {}

    return f"{TEST_PREFIX}value"


def generate_test_cases(tool):
    """Generate edge case test cases for a tool based on its schema."""
    tool_name = tool["name"]
    params = extract_schema_info(tool)
    required_params = [p for p in params if p["required"]]
    string_params = [p for p in params if p["type"] == "string"]
    int_params = [p for p in params if p["type"] in ("integer", "number")]
    cases = []

    # --- Happy path: all valid inputs ---
    valid_args = {}
    for p in params:
        valid_args[p["name"]] = generate_valid_value(p)
    cases.append({
        "name": f"{tool_name}:happy_path",
        "args": valid_args,
        "expect": "success",
        "category": "happy_path",
    })

    # --- Missing required fields (one at a time) ---
    for rp in required_params:
        partial = {p["name"]: generate_valid_value(p) for p in params}
        del partial[rp["name"]]
        cases.append({
            "name": f"{tool_name}:missing_{rp['name']}",
            "args": partial,
            "expect": "error",
            "category": "missing_required",
        })

    # --- Empty string for required strings ---
    for rp in required_params:
        if rp["type"] == "string":
            args = {p["name"]: generate_valid_value(p) for p in params}
            args[rp["name"]] = ""
            cases.append({
                "name": f"{tool_name}:empty_{rp['name']}",
                "args": args,
                "expect": "error",
                "category": "empty_string",
            })

    # --- Whitespace-only for required strings ---
    for rp in required_params:
        if rp["type"] == "string":
            args = {p["name"]: generate_valid_value(p) for p in params}
            args[rp["name"]] = "   "
            cases.append({
                "name": f"{tool_name}:whitespace_{rp['name']}",
                "args": args,
                "expect": "error",
                "category": "whitespace_only",
            })

    # --- SQL injection on first string param ---
    if string_params:
        sp = string_params[0]
        args = {p["name"]: generate_valid_value(p) for p in params}
        args[sp["name"]] = SQL_INJECTION
        cases.append({
            "name": f"{tool_name}:sql_injection_{sp['name']}",
            "args": args,
            "expect": "no_crash",
            "category": "sql_injection",
        })

    # --- Oversized string on first string param ---
    if string_params:
        sp = string_params[0]
        args = {p["name"]: generate_valid_value(p) for p in params}
        args[sp["name"]] = OVERSIZED
        cases.append({
            "name": f"{tool_name}:oversized_{sp['name']}",
            "args": args,
            "expect": "no_crash",
            "category": "oversized_input",
        })

    # --- Boundary values for int/number params ---
    for ip in int_params:
        if "limit" in ip["name"] or "offset" in ip["name"]:
            for val, label in [(-1, "negative"), (0, "zero"), (999999, "huge")]:
                args = {p["name"]: generate_valid_value(p) for p in params}
                args[ip["name"]] = val
                cases.append({
                    "name": f"{tool_name}:{ip['name']}_{label}",
                    "args": args,
                    "expect": "no_crash",
                    "category": "boundary_value",
                })

    # --- Not found (for singular get/update/delete tools, not list/search/filter) ---
    is_singular = any(kw in tool_name for kw in ["get_", "update_", "delete_", "move_", "void_"])
    is_list = any(kw in tool_name for kw in ["list_", "search_", "query_", "get_commissions", "get_pipeline"])
    if is_singular and not is_list:
        id_params = [p for p in params if "id" in p["name"].lower() and p["type"] == "string"]
        if id_params:
            args = {p["name"]: generate_valid_value(p) for p in params}
            args[id_params[0]["name"]] = str(uuid.uuid4())  # fake UUID
            cases.append({
                "name": f"{tool_name}:not_found",
                "args": args,
                "expect": "error",
                "category": "not_found",
            })

    return cases


def evaluate_result(resp, expect):
    """Evaluate if a test case passed based on response and expectation."""
    if resp is None:
        return "FAIL", "Timeout - no response"

    if "error" in resp:
        # JSON-RPC level error (protocol error, not tool error)
        return "FAIL", f"JSON-RPC error: {resp['error']}"

    result = resp.get("result", {})
    content = result.get("content", [{}])
    is_error = result.get("isError", False)
    text = content[0].get("text", "") if content else ""

    if expect == "success":
        if is_error:
            return "FAIL", f"Expected success, got error: {text[:200]}"
        return "PASS", text[:100]

    if expect == "error":
        if is_error:
            return "PASS", f"Got expected error: {text[:100]}"
        return "FAIL", f"Expected error but got success: {text[:100]}"

    if expect == "no_crash":
        # As long as we got a valid response (error or success), it didn't crash
        return "PASS", f"No crash (isError={is_error}): {text[:100]}"

    return "FAIL", f"Unknown expect: {expect}"


def _extract_id_from_response(resp):
    """Try to extract an ID from a tool call response."""
    if not resp:
        return None
    result = resp.get("result", {})
    content = result.get("content", [{}])
    text = content[0].get("text", "") if content else ""
    try:
        data = json.loads(text)
        if isinstance(data, dict):
            return data.get("id")
        if isinstance(data, list) and data:
            return data[0].get("id")
    except:
        pass
    return None


def _find_create_tool(tools, tool_name):
    """Find the matching create tool for a get/update/delete tool."""
    # get_note -> create_note, delete_contact -> create_contact
    entity = tool_name.split("_", 1)[1] if "_" in tool_name else ""
    create_name = f"create_{entity}"
    for t in tools:
        if t["name"] == create_name:
            return t
    # Also try: get_manager -> create_manager, update_commission_status -> record_commission
    for t in tools:
        if t["name"].startswith("create_") or t["name"].startswith("add_") or t["name"].startswith("record_"):
            return t
    return None


def run_tests(binary_path, json_output=False, report_path=None):
    """Run all E2E tests against an MCP binary."""
    mcp_name = os.path.basename(binary_path)
    client = McpClient(binary_path)
    results = {"mcp": mcp_name, "tests": [], "summary": {}}

    try:
        client.start()
        client.initialize()
        tools = client.list_tools()
    except Exception as e:
        results["error"] = str(e)
        _output(results, json_output, report_path)
        client.stop()
        return results

    if not json_output:
        print(f"\n{'='*60}")
        print(f"  E2E Testing: {mcp_name} ({len(tools)} tools)")
        print(f"{'='*60}")

    total = pass_count = fail_count = 0
    category_stats = {}
    # Cache of created entity IDs for chaining
    created_ids = {}

    for tool in tools:
        cases = generate_test_cases(tool)
        for case in cases:
            total += 1

            # For happy_path on get/update/delete, try to create entity first
            if case["category"] == "happy_path" and any(kw in tool["name"] for kw in ["get_", "update_", "delete_", "move_", "record_", "add_", "log_", "assign_", "submit_", "advance_", "enroll_", "send_", "fire_", "retry_", "score_", "push_"]):
                id_params = [p for p in extract_schema_info(tool) if "id" in p["name"].lower() and p["type"] == "string"]
                if id_params:
                    id_key = id_params[0]["name"]
                    # Try to find a cached ID — check exact key, then generic "id"
                    cached_id = created_ids.get(id_key) or created_ids.get("id")
                    if not cached_id:
                        # Try to create an entity first
                        create_tool = _find_create_tool(tools, tool["name"])
                        if create_tool:
                            create_params = extract_schema_info(create_tool)
                            create_args = {p["name"]: generate_valid_value(p) for p in create_params}
                            # If create tool needs a foreign ID we already have, inject it
                            for cp in create_params:
                                if cp["name"] in created_ids:
                                    create_args[cp["name"]] = created_ids[cp["name"]]
                            create_resp = client.call_tool(create_tool["name"], create_args)
                            eid = _extract_id_from_response(create_resp)
                            if eid:
                                created_ids[id_key] = eid
                                cached_id = eid
                    if cached_id:
                        case["args"][id_key] = cached_id

            try:
                resp = client.call_tool(tool["name"], case["args"])
                status, detail = evaluate_result(resp, case["expect"])

                # Cache any ID from successful creates
                if case["category"] == "happy_path" and status == "PASS":
                    eid = _extract_id_from_response(resp)
                    if eid:
                        # Figure out what ID param name to use
                        for p in extract_schema_info(tool):
                            if "id" in p["name"].lower():
                                created_ids[p["name"]] = eid
                                break
                        # Also cache as generic "id"
                        created_ids["id"] = eid

            except Exception as e:
                status, detail = "FAIL", f"Exception: {e}"

            if status == "PASS":
                pass_count += 1
            else:
                fail_count += 1

            cat = case["category"]
            category_stats.setdefault(cat, {"pass": 0, "fail": 0})
            category_stats[cat]["pass" if status == "PASS" else "fail"] += 1

            results["tests"].append({
                "name": case["name"],
                "category": cat,
                "status": status,
                "detail": detail,
                "args_summary": {k: type(v).__name__ for k, v in case["args"].items()},
            })

            if not json_output:
                icon = "PASS" if status == "PASS" else "FAIL"
                print(f"  {icon}  {case['name']}")
                if status == "FAIL":
                    print(f"        {detail}")

    client.stop()

    results["summary"] = {
        "total": total,
        "pass": pass_count,
        "fail": fail_count,
        "pass_rate": f"{pass_count/total*100:.1f}%" if total > 0 else "N/A",
        "categories": category_stats,
    }

    if not json_output:
        print(f"\n{'─'*60}")
        print(f"  Results: {pass_count}/{total} passed ({results['summary']['pass_rate']})")
        print(f"  Categories:")
        for cat, stats in sorted(category_stats.items()):
            status_icon = "OK" if stats["fail"] == 0 else "!!"
            print(f"    {status_icon} {cat}: {stats['pass']} pass, {stats['fail']} fail")
        print()

    _output(results, json_output, report_path)
    return results


def _output(results, json_output, report_path):
    if report_path:
        with open(report_path, "w") as f:
            json.dump(results, f, indent=2)
    if json_output:
        print(json.dumps(results, indent=2))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <binary_path> [--json] [--report <path>]")
        sys.exit(1)

    binary = sys.argv[1]
    json_mode = "--json" in sys.argv
    report = None
    if "--report" in sys.argv:
        idx = sys.argv.index("--report")
        report = sys.argv[idx + 1] if idx + 1 < len(sys.argv) else f"/tmp/e2e_{os.path.basename(binary)}.json"

    if not os.path.isfile(binary):
        print(f"Binary not found: {binary}")
        sys.exit(1)

    results = run_tests(binary, json_output=json_mode, report_path=report)
    sys.exit(0 if results["summary"].get("fail", 0) == 0 else 1)
