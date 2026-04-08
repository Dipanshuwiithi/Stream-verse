# Stage 1 — Build frontend
FROM node:20-alpine AS builder

RUN apk add --no-cache git

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build


# Stage 2 — Runtime container with streaming server
FROM stremio/server:latest

WORKDIR /app

# Copy built frontend
COPY --from=builder /app/build ./build
COPY http_server.js ./http_server.js

# Install Node to serve frontend
RUN apk add --no-cache nodejs npm

EXPOSE 8080
EXPOSE 11470

# Run frontend + streaming server together
CMD sh -c "node http_server.js & ./server"