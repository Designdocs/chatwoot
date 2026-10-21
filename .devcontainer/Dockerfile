# The below image is created out of the Dockerfile.base
# It has the dependencies already installed so that codespace will boot up fast
ARG NODE_VERSION=24.22.1
FROM node:${NODE_VERSION}-bookworm-slim AS node
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

COPY --from=node /usr/local/bin/node /usr/local/bin/node

# Do the set up required for chatwoot app
WORKDIR /workspace

# Copy dependency files first for better caching
COPY package.json pnpm-lock.yaml ./
COPY Gemfile Gemfile.lock ./

# Install dependencies (will be cached if files don't change)
RUN pnpm install --frozen-lockfile && \
    gem install bundler && \
    bundle install --jobs=$(nproc)

# Copy source code after dependencies are installed
COPY . /workspace
