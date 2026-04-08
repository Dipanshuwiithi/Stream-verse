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


# Stage 2 — Runtime container
FROM stremio/server:latest

WORKDIR /app

# Copy frontend build
COPY --from=builder /app/build ./build
COPY http_server.js ./http_server.js

EXPOSE 8080
EXPOSE 11470

# Start frontend + streaming server together
CMD sh -c "node http_server.js & ./server"