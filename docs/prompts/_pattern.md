# DataXLR8 Lego Pattern — Agent Reference

Every MCP follows this exact structure. No exceptions.

## File Structure

```
dataxlr8-{name}-mcp/
├── .gitignore          # /target
├── Cargo.toml          # rmcp 0.17, dataxlr8-mcp-core (path), sqlx, tokio, serde
├── src/
│   ├── main.rs         # config → logging → db → schema → server → stdio
│   ├── db.rs           # CREATE SCHEMA IF NOT EXISTS {name}; + tables
│   └── tools/
│       └── mod.rs      # types → schema helpers → build_tools() → handlers → ServerHandler
```

## Cargo.toml Template

```toml
[package]
name = "dataxlr8-{name}-mcp"
version = "0.1.0"
edition = "2024"

[dependencies]
rmcp = { version = "0.17", features = ["server", "transport-io"] }
dataxlr8-mcp-core = { path = "../dataxlr8-mcp-core" }
sqlx = { version = "0.8", features = ["runtime-tokio", "tls-rustls", "postgres", "migrate", "chrono", "uuid", "json"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
anyhow = "1"
tracing = "0.1"
chrono = { version = "0.4", features = ["serde"] }
uuid = { version = "1", features = ["v4", "serde"] }
```

## main.rs Pattern

```rust
use anyhow::Result;
use dataxlr8_mcp_core::{Config, Database};
use rmcp::ServiceExt;
use rmcp::transport::stdio;
use tracing::info;

mod db;
mod tools;
use tools::MyMcpServer;

#[tokio::main]
async fn main() -> Result<()> {
    let config = Config::from_env("dataxlr8-{name}-mcp")?;
    dataxlr8_mcp_core::logging::init(&config.log_level);
    info!("Starting dataxlr8-{name}-mcp...");
    let database = Database::connect(&config.database_url).await?;
    db::setup_schema(database.pool()).await?;
    let server = MyMcpServer::new(database.pool().clone());
    let service = server.serve(stdio()).await?;
    service.waiting().await?;
    Ok(())
}
```

## db.rs Pattern

```rust
use anyhow::Result;
use sqlx::PgPool;

pub async fn setup_schema(pool: &PgPool) -> Result<()> {
    sqlx::raw_sql(r#"
        CREATE SCHEMA IF NOT EXISTS {name};
        CREATE TABLE IF NOT EXISTS {name}.{table} ( ... );
        CREATE INDEX IF NOT EXISTS idx_{table}_{col} ON {name}.{table}({col});
    "#)
    .execute(pool)
    .await?;
    Ok(())
}
```

## tools/mod.rs Pattern

Use shared helpers from `dataxlr8_mcp_core::mcp`:

```rust
use dataxlr8_mcp_core::mcp::{make_schema, empty_schema, json_result, error_result, get_str, get_i64, get_bool, get_str_array};
use rmcp::model::*;
use rmcp::service::{RequestContext, RoleServer};
use rmcp::ServerHandler;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

// 1. Define data types (structs with Serialize, Deserialize, sqlx::FromRow)
// 2. Define build_tools() → Vec<Tool> with schemas
// 3. Implement handler methods on the server struct
// 4. Implement ServerHandler trait (get_info, list_tools, call_tool)
```

## Standards

| Metric | Target |
|--------|--------|
| Binary size | < 7MB |
| Memory | < 10MB |
| Tool call latency | < 0.2ms (excluding external calls) |
| Cold start | < 5ms |
| Database | PostgreSQL via sqlx, schema-per-MCP |
| MCP SDK | rmcp v0.17 |
| License | MIT |
