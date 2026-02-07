# hubspot-mcp-extended-http

Containerized wrapper for [calypsoCodex/hubspot-mcp-extended](https://github.com/calypsoCodex/hubspot-mcp-extended) exposing 106 HubSpot MCP tools over **Streamable HTTP** transport.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Docker Container                               │
│                                                 │
│  supergateway (port 8000)                       │
│    --outputTransport streamableHttp             │
│    │                                            │
│    └── stdio ──► hubspot-mcp-extended           │
│                    (node build/index.js)         │
│                                                 │
└─────────────────────────────────────────────────┘
         ▲
         │  POST /mcp  (Streamable HTTP)
         │
    MCP Client (Obot, n8n, Claude Desktop, etc.)
```

The MCP Streamable HTTP transport uses a single `/mcp` endpoint:
- **POST /mcp** — Send JSON-RPC requests, receive responses (optionally streamed via SSE)
- **GET /mcp** — Open SSE stream for server-initiated notifications
- **DELETE /mcp** — Terminate session
- Session tracking via `Mcp-Session-Id` header

## Quick Start

```bash
cp .env.example .env
# Edit .env with your HubSpot Private App token

docker compose up -d
```

The server will be available at `http://localhost:8000/mcp`.

Health check: `http://localhost:8000/healthz`

## Connecting to Obot

In the Obot admin UI, add a new MCP server:

- **Type:** Remote (Streamable HTTP)
- **URL:** `http://hubspot-mcp-extended:8000/mcp`
  (or `http://<host-ip>:8000/mcp` if not on the same Docker network)

## Connecting to n8n

In an n8n MCP Client node:

- **Transport:** Streamable HTTP
- **URL:** `http://hubspot-mcp-extended:8000/mcp`

## Available Tools (106)

Includes full CRUD for: Contacts, Companies, Deals, Tickets, Line Items, Products, Quotes, Invoices, Tasks, Notes, Emails, Calls, Meetings, Communications, Feedback Submissions, Custom Objects, Owners, Pipelines, Properties, Associations, and Batch Operations.

## Pin to a specific version

Edit the `Dockerfile` and change the `git clone` line:

```dockerfile
RUN git clone --depth 1 --branch v1.4.0 https://github.com/calypsoCodex/hubspot-mcp-extended.git .
```

## License

This wrapper is MIT. The upstream hubspot-mcp-extended is dual-licensed (MIT / Commercial).
