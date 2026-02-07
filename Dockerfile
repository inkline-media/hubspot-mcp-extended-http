FROM node:20-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y git && \
    git clone --depth 1 https://github.com/calypsoCodex/hubspot-mcp-extended.git . && \
    npm install && \
    npm run build && \
    npm prune --production

FROM node:20-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Copy built app and production deps from builder
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Install supergateway globally for stdio → Streamable HTTP bridging
RUN npm install -g supergateway

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -sf http://localhost:8000/healthz || exit 1

# Bridge: stdio → Streamable HTTP
# Endpoint: http://localhost:8000/mcp
CMD ["supergateway", \
     "--stdio", "node /app/build/index.js", \
     "--outputTransport", "streamableHttp", \
     "--port", "8000", \
     "--healthEndpoint", "/healthz", \
     "--cors", \
     "--logLevel", "info"]
