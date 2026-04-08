# Base Node image
FROM node:20-alpine

# Install dependencies
RUN apk add --no-cache git curl bash

# Enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app

# Install frontend dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy project and build
COPY . .
RUN pnpm build

# Install official Stremio streaming server binary
RUN mkdir /streaming-server && \
    cd /streaming-server && \
    curl -L https://github.com/Stremio/server/releases/download/v4.20.8/server-linux-x64.tar.gz \
    -o server.tar.gz && \
    tar -xzf server.tar.gz

# Copy HTTP server
COPY http_server.js .

EXPOSE 8080
EXPOSE 11470

# Run frontend + streaming engine together
CMD sh -c "node http_server.js & /streaming-server/server"