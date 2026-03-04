# BRD: dataxlr8-mcp-core

**Type:** Shared library (not an MCP server)
**Phase:** 0
**Status:** VERIFIED
**Repo:** [pdaxt/dataxlr8-mcp-core](https://github.com/pdaxt/dataxlr8-mcp-core)

---

## Purpose

Shared Rust crate that all DataXLR8 MCP servers depend on. Eliminates boilerplate by providing common infrastructure.

## Provides

| Module | What It Does |
|--------|-------------|
| `config.rs` | Loads `DATABASE_URL` and `RUST_LOG` from env/.env file |
| `db.rs` | PostgreSQL connection pool (sqlx, 5 connections, 10s timeout) |
| `error.rs` | `McpError` type with error codes (ConfigError, DatabaseError, etc.) |
| `logging.rs` | Structured tracing to stderr |

## Public API

```rust
// Config
Config::from_env("server-name") -> Result<Config, McpError>

// Database
Database::connect(&database_url) -> Result<Database, McpError>
Database::pool() -> &PgPool
Database::execute_raw(&sql) -> Result<(), McpError>  // Schema setup
Database::close()

// Errors
McpError::new(code, message)
McpError::database(message)

// Re-exports
pub use sqlx::PgPool;
```

## Config Format

| Env Var | Required | Default | Description |
|---------|----------|---------|-------------|
| `DATABASE_URL` | Yes | — | `postgres://user:pass@host:port/dbname` |
| `RUST_LOG` | No | `info` | Log level filter |

## Security

- `Config::Debug` redacts `database_url` (prints `[REDACTED]`)
- Connection pool limited to 5 connections
- 10-second acquire timeout prevents hanging

## Acceptance

- [x] `cargo build` and `cargo build --release`
- [x] Used successfully by dataxlr8-features-mcp
- [x] Connects to local PostgreSQL
- [x] Schema execution works (tested via features-mcp)
