ARG NODE_VERSION=20-alpine
FROM node:$NODE_VERSION

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

# Copy source and build frontend
COPY . .
RUN pnpm build

# Install Stremio streaming server
RUN mkdir /streaming-server && \
    cd /streaming-server && \
    wget https://dl.strem.io/server/v4.20.11/server-linux-x64.tar.gz && \
    tar -xzf server-linux-x64.tar.gz

# Copy HTTP server
COPY http_server.js .

EXPOSE 8080
EXPOSE 11470

# Start frontend + streaming engine together
CMD sh -c "node http_server.js & /streaming-server/server"