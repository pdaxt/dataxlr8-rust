#!/usr/bin/env bash
# scaffold-mcp.sh — Generate a new DataXLR8 Rust MCP server from template
#
# Usage: ./scripts/scaffold-mcp.sh <mcp-name> <pg-schema>
# Example: ./scripts/scaffold-mcp.sh contacts contacts
#          ./scripts/scaffold-mcp.sh commissions commissions
#
# Creates: ~/Projects/dataxlr8-<mcp-name>-mcp/
#   ├── Cargo.toml
#   ├── .env
#   ├── .env.example
#   ├── .gitignore
#   ├── src/
#   │   ├── main.rs
#   │   ├── db.rs
#   │   └── tools/
#   │       └── mod.rs
#   └── README.md

set -uo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <mcp-name> <pg-schema>"
    echo "Example: $0 contacts contacts"
    exit 1
fi

NAME="$1"
SCHEMA="$2"
REPO_NAME="dataxlr8-${NAME}-mcp"
TARGET_DIR="$HOME/Projects/${REPO_NAME}"

if [ -d "$TARGET_DIR" ]; then
    echo "ERROR: $TARGET_DIR already exists"
    exit 1
fi

echo "Scaffolding ${REPO_NAME} → ${TARGET_DIR}"

mkdir -p "$TARGET_DIR/src/tools"

# Cargo.toml
cat > "$TARGET_DIR/Cargo.toml" << 'CARGO_EOF'
[package]
name = "REPO_NAME_PLACEHOLDER"
version = "0.1.0"
edition = "2024"
description = "MCP_DESC_PLACEHOLDER MCP server for DataXLR8 platform"
repository = "https://github.com/pdaxt/REPO_NAME_PLACEHOLDER"

[dependencies]
# MCP SDK
rmcp = { version = "0.17", features = ["server", "transport-io"] }

# Shared core
dataxlr8-mcp-core = { path = "../dataxlr8-mcp-core" }

# Database
sqlx = { version = "0.8", features = [
    "runtime-tokio",
    "tls-rustls",
    "postgres",
    "migrate",
    "chrono",
    "uuid",
] }

# Async
tokio = { version = "1", features = ["full"] }

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Error handling
anyhow = "1"

# Logging
tracing = "0.1"

# Types
chrono = { version = "0.4", features = ["serde"] }
uuid = { version = "1", features = ["v4", "serde"] }
CARGO_EOF

sed -i '' "s/REPO_NAME_PLACEHOLDER/${REPO_NAME}/g" "$TARGET_DIR/Cargo.toml"
sed -i '' "s/MCP_DESC_PLACEHOLDER/${NAME^}/g" "$TARGET_DIR/Cargo.toml"

# .env
cat > "$TARGET_DIR/.env" << 'ENV_EOF'
DATABASE_URL=postgres://pran@localhost/dataxlr8
RUST_LOG=info
ENV_EOF

cp "$TARGET_DIR/.env" "$TARGET_DIR/.env.example"

# .gitignore
cat > "$TARGET_DIR/.gitignore" << 'GIT_EOF'
/target
.env
GIT_EOF

# src/main.rs
cat > "$TARGET_DIR/src/main.rs" << MAIN_EOF
use anyhow::Result;
use rmcp::transport::io::stdio;
use rmcp::ServiceExt;
use tracing::info;

mod db;
mod tools;

use tools::${NAME^}McpServer;

#[tokio::main]
async fn main() -> Result<()> {
    let config = dataxlr8_mcp_core::Config::from_env("${REPO_NAME}")
        .map_err(|e| anyhow::anyhow!("{e}"))?;

    dataxlr8_mcp_core::logging::init(&config.log_level);

    info!(
        server = config.server_name,
        "Starting DataXLR8 ${NAME^} MCP server"
    );

    let database = dataxlr8_mcp_core::Database::connect(&config.database_url)
        .await
        .map_err(|e| anyhow::anyhow!("{e}"))?;

    // Run schema setup
    db::setup_schema(database.pool()).await?;

    let server = ${NAME^}McpServer::new(database.clone());

    let transport = stdio();
    let service = server.serve(transport).await?;

    info!("${NAME^} MCP server connected via stdio");

    // Wait for either service completion or shutdown signal
    tokio::select! {
        result = service.waiting() => {
            result?;
            info!("MCP service ended");
        }
        _ = tokio::signal::ctrl_c() => {
            info!("Received shutdown signal");
        }
    }

    // Graceful shutdown
    database.close().await;
    info!("${NAME^} MCP server shut down");

    Ok(())
}
MAIN_EOF

# src/db.rs
cat > "$TARGET_DIR/src/db.rs" << DB_EOF
use anyhow::Result;
use sqlx::PgPool;

/// Create the ${SCHEMA} schema in PostgreSQL if it doesn't exist.
pub async fn setup_schema(pool: &PgPool) -> Result<()> {
    sqlx::raw_sql(
        r#"
        CREATE SCHEMA IF NOT EXISTS ${SCHEMA};

        -- TODO: Add your tables here
        -- Example:
        -- CREATE TABLE IF NOT EXISTS ${SCHEMA}.items (
        --     id          TEXT PRIMARY KEY,
        --     name        TEXT NOT NULL,
        --     created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
        --     updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        -- );
        "#,
    )
    .execute(pool)
    .await?;

    Ok(())
}
DB_EOF

# src/tools/mod.rs
cat > "$TARGET_DIR/src/tools/mod.rs" << TOOLS_EOF
use dataxlr8_mcp_core::Database;
use rmcp::model::*;
use rmcp::service::{RequestContext, RoleServer};
use rmcp::ServerHandler;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tracing::{error, info};

// ============================================================================
// Data types
// ============================================================================

// TODO: Define your data types here
// #[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
// pub struct Item { ... }

// ============================================================================
// Tool schema helpers
// ============================================================================

fn make_schema(properties: serde_json::Value, required: Vec<&str>) -> Arc<serde_json::Map<String, serde_json::Value>> {
    let mut m = serde_json::Map::new();
    m.insert("type".to_string(), serde_json::Value::String("object".to_string()));
    m.insert("properties".to_string(), properties);
    if !required.is_empty() {
        m.insert(
            "required".to_string(),
            serde_json::Value::Array(required.into_iter().map(|s| serde_json::Value::String(s.to_string())).collect()),
        );
    }
    Arc::new(m)
}

fn empty_schema() -> Arc<serde_json::Map<String, serde_json::Value>> {
    let mut m = serde_json::Map::new();
    m.insert("type".to_string(), serde_json::Value::String("object".to_string()));
    Arc::new(m)
}

fn build_tools() -> Vec<Tool> {
    vec![
        // TODO: Define your tools here
        // Tool {
        //     name: "list_items".into(),
        //     title: None,
        //     description: Some("List all items".into()),
        //     input_schema: empty_schema(),
        //     output_schema: None,
        //     annotations: None,
        //     execution: None,
        //     icons: None,
        //     meta: None,
        // },
    ]
}

// ============================================================================
// MCP Server
// ============================================================================

#[derive(Clone)]
pub struct ${NAME^}McpServer {
    db: Database,
}

impl ${NAME^}McpServer {
    pub fn new(db: Database) -> Self {
        Self { db }
    }

    fn json_result<T: Serialize>(data: &T) -> CallToolResult {
        match serde_json::to_string_pretty(data) {
            Ok(json) => CallToolResult::success(vec![Content::text(json)]),
            Err(e) => CallToolResult::error(vec![Content::text(format!("Serialization error: {e}"))]),
        }
    }

    fn error_result(msg: &str) -> CallToolResult {
        CallToolResult::error(vec![Content::text(msg.to_string())])
    }

    fn get_str(args: &serde_json::Value, key: &str) -> Option<String> {
        args.get(key).and_then(|v| v.as_str()).map(String::from)
    }

    fn get_bool(args: &serde_json::Value, key: &str) -> Option<bool> {
        args.get(key).and_then(|v| v.as_bool())
    }

    // TODO: Add tool handler methods here
}

// ============================================================================
// ServerHandler trait implementation
// ============================================================================

impl ServerHandler for ${NAME^}McpServer {
    fn get_info(&self) -> ServerInfo {
        ServerInfo {
            protocol_version: ProtocolVersion::V_2024_11_05,
            capabilities: ServerCapabilities::builder()
                .enable_tools()
                .build(),
            server_info: Implementation::from_build_env(),
            instructions: Some(
                "DataXLR8 ${NAME^} MCP — TODO: describe this server"
                    .into(),
            ),
        }
    }

    fn list_tools(
        &self,
        _request: Option<PaginatedRequestParams>,
        _context: RequestContext<RoleServer>,
    ) -> impl std::future::Future<Output = Result<ListToolsResult, rmcp::ErrorData>> + Send + '_ {
        async {
            Ok(ListToolsResult {
                tools: build_tools(),
                next_cursor: None,
                meta: None,
            })
        }
    }

    fn call_tool(
        &self,
        request: CallToolRequestParams,
        _context: RequestContext<RoleServer>,
    ) -> impl std::future::Future<Output = Result<CallToolResult, rmcp::ErrorData>> + Send + '_ {
        async move {
            let args = serde_json::to_value(&request.arguments).unwrap_or(serde_json::Value::Null);
            let name_str: &str = request.name.as_ref();

            let result = match name_str {
                // TODO: Route tools here
                // "list_items" => self.handle_list_items().await,
                _ => Self::error_result(&format!("Unknown tool: {}", request.name)),
            };

            Ok(result)
        }
    }
}
TOOLS_EOF

echo ""
echo "Created ${REPO_NAME} at ${TARGET_DIR}"
echo ""
echo "Next steps:"
echo "  1. cd ${TARGET_DIR}"
echo "  2. Edit src/db.rs — add your CREATE TABLE statements"
echo "  3. Edit src/tools/mod.rs — add data types, tool defs, handlers"
echo "  4. cargo build --release"
echo "  5. Test with: ../dataxlr8-rust/scripts/test-mcp.sh ./target/release/${REPO_NAME}"
echo ""
echo "Refer to: ~/Projects/dataxlr8-rust/docs/mcps/${NAME}.md for the BRD spec"
