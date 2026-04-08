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


# Stage 2 — Get streaming server binary
FROM stremio/server:latest AS streaming


# Stage 3 — Final runtime image
FROM node:20-alpine

WORKDIR /app

# Copy frontend build
COPY --from=builder /app/build ./build
COPY http_server.js ./http_server.js

# Copy streaming server binary
COPY --from=streaming /usr/bin/server ./server

EXPOSE 8080
EXPOSE 11470

# Start frontend + streaming engine
CMD ["sh", "-c", "node http_server.js & ./server"]