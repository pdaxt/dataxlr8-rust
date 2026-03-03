# Setup Guide — Running DataXLR8 Rust MCPs

## Prerequisites

1. **Rust toolchain** (installed via rustup)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **PostgreSQL 17** (local install or Docker)

3. **Git** (for cloning repos)

---

## Step 1: Install PostgreSQL

### Option A: Docker (recommended)
```bash
docker run -d \
  --name dataxlr8-postgres \
  -e POSTGRES_USER=dataxlr8 \
  -e POSTGRES_PASSWORD=dataxlr8 \
  -e POSTGRES_DB=dataxlr8 \
  -p 5432:5432 \
  postgres:17-alpine
```

### Option B: Direct Install (Windows)
1. Download from https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
2. Run installer — set password to `dataxlr8`, keep port `5432`
3. Create the database:
   ```bash
   psql -U postgres -c "CREATE USER dataxlr8 WITH PASSWORD 'dataxlr8';"
   psql -U postgres -c "CREATE DATABASE dataxlr8 OWNER dataxlr8;"
   ```

### Option C: Direct Install (macOS)
```bash
brew install postgresql@17
brew services start postgresql@17
createuser -s dataxlr8
createdb dataxlr8 -O dataxlr8
psql dataxlr8 -c "ALTER USER dataxlr8 PASSWORD 'dataxlr8';"
```

---

## Step 2: Clone the Repos

```bash
# Create project directory
mkdir -p ~/dataxlr8-rust && cd ~/dataxlr8-rust

# Clone shared core library
git clone https://github.com/pdaxt/dataxlr8-mcp-core.git

# Clone features MCP (proof of concept)
git clone https://github.com/pdaxt/dataxlr8-features-mcp.git
```

---

## Step 3: Configure Environment

Create `.env` in the features MCP directory:

```bash
cd dataxlr8-features-mcp
cat > .env << 'EOF'
DATABASE_URL=postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8
RUST_LOG=info
EOF
```

---

## Step 4: Build

```bash
# Build the features MCP (release mode)
cd dataxlr8-features-mcp
cargo build --release

# Binary will be at: target/release/dataxlr8-features-mcp (or .exe on Windows)
```

---

## Step 5: Test Manually

The MCP server communicates via JSON-RPC over stdin/stdout. You can test it by piping JSON:

```bash
# List all tools
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./target/release/dataxlr8-features-mcp

# Create a feature flag
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"create_flag","arguments":{"name":"dark_mode","flag_type":"global","description":"Enable dark mode UI","enabled":true}}}' | ./target/release/dataxlr8-features-mcp

# Get all flags
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"get_all_flags","arguments":{}}}' | ./target/release/dataxlr8-features-mcp

# Check a flag with role override
echo '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"check_flag","arguments":{"name":"dark_mode","employee_id":"emp-123","role":"admin"}}}' | ./target/release/dataxlr8-features-mcp

# Set a role override
echo '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"set_override","arguments":{"flag_name":"dark_mode","override_type":"role","target":"admin","enabled":false}}}' | ./target/release/dataxlr8-features-mcp

# Bulk check flags
echo '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"check_flags_bulk","arguments":{"names":["dark_mode","beta_features"],"role":"admin"}}}' | ./target/release/dataxlr8-features-mcp

# Delete a flag
echo '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"delete_flag","arguments":{"name":"dark_mode"}}}' | ./target/release/dataxlr8-features-mcp
```

---

## Step 6: Connect to Claude Desktop

Add to your Claude Desktop config (`%APPDATA%/Claude/claude_desktop_config.json` on Windows, `~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "dataxlr8-features": {
      "command": "C:/Users/homay/dataxlr8-rust/dataxlr8-features-mcp/target/release/dataxlr8-features-mcp.exe",
      "env": {
        "DATABASE_URL": "postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8",
        "RUST_LOG": "info"
      }
    }
  }
}
```

Restart Claude Desktop. You should see the 8 feature flag tools available.

---

## Step 7: Verify in Claude Desktop

Ask Claude:
- "List all feature flags"
- "Create a feature flag called 'new_dashboard' with type 'page' and description 'Enable new dashboard UI'"
- "Check if 'new_dashboard' is enabled for role 'admin'"
- "Set an override for 'new_dashboard' to disable it for role 'viewer'"

---

## Troubleshooting

### "Connection refused" error
PostgreSQL is not running. Start it:
- Docker: `docker start dataxlr8-postgres`
- Windows service: `net start postgresql-x64-17`
- macOS: `brew services start postgresql@17`

### "DATABASE_URL environment variable is required"
The `.env` file is not in the working directory, or the environment variable is not set.

### Server exits immediately
Check stderr output — the MCP server logs to stderr. The server may be crashing on schema setup if the database doesn't exist.

### Tool calls return errors
Check that the `features` schema was created. Connect to PostgreSQL and run:
```sql
SELECT * FROM features.flags;
```

---

## Connection String Format

```
postgres://USER:PASSWORD@HOST:PORT/DATABASE
```

Examples:
- Local: `postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8`
- Docker: `postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8`
- Remote: `postgres://dataxlr8:secret@db.example.com:5432/dataxlr8`
