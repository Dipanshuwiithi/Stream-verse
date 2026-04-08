# Base Node image
ARG NODE_VERSION=20-alpine
FROM node:$NODE_VERSION AS base

# Enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable
RUN apk add --no-cache git curl bash

WORKDIR /var/www/stremio-web

# Install dependencies
FROM base AS app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

# Download Stremio streaming server
FROM base AS streaming

WORKDIR /streaming-server

RUN curl -L https://github.com/Stremio/server/releases/latest/download/server-linux-x64.tar.gz \
    | tar -xz

# Final container
FROM base

WORKDIR /var/www/stremio-web

COPY http_server.js ./
COPY --from=app /var/www/stremio-web/build ./build
COPY --from=app /var/www/stremio-web/node_modules ./node_modules
COPY --from=streaming /streaming-server ./streaming-server

# Expose ports
EXPOSE 8080
EXPOSE 11470

# Run both frontend + streaming engine
CMD sh -c "node http_server.js & ./streaming-server/server"