# The below image is created out of the Dockerfile.base
# It has the dependencies already installed so that codespace will boot up fast
ARG NODE_VERSION=24.22.1
# The published codespace base currently supports amd64 only.
ARG CODESPACE_PLATFORM=linux/amd64
FROM --platform=${CODESPACE_PLATFORM} node:${NODE_VERSION}-bookworm-slim AS node
FROM --platform=${CODESPACE_PLATFORM} ghcr.io/chatwoot/chatwoot_codespace:latest

USER root
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -sf /usr/local/bin/node /usr/bin/node \
    && ln -sf node /usr/bin/nodejs
USER vscode

# Do the set up required for chatwoot app
WORKDIR /workspace

# Copy dependency files first for better caching
COPY --chown=vscode:vscode package.json pnpm-lock.yaml ./
COPY --chown=vscode:vscode Gemfile Gemfile.lock ./

# Install dependencies (will be cached if files don't change)
RUN pnpm install --frozen-lockfile && \
    gem install bundler && \
    bundle install --jobs=$(nproc)

# Copy source code after dependencies are installed
COPY --chown=vscode:vscode . /workspace
