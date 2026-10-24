FROM alpine:3.24 AS apk-builder
ENV SUDO_APK=apk
RUN apk add --no-cache abuild build-base cargo cargo-auditable cargo-c ca-certificates curl \
  && apk update \
  && abuild-keygen -a -n \
  && cp /root/.abuild/*.pub /etc/apk/keys/ \
  && mkdir /package-keys \
  && cp /root/.abuild/*.pub /package-keys/

FROM apk-builder AS curl-packages
ARG CURL_TEST_FLAGS=""
COPY docker/packages/curl /build/curl
WORKDIR /build/curl
RUN abuild -F -r -K -P /packages deps fetch unpack prepare build
RUN --network=none abuild -F -K check
RUN abuild -F -K -P /packages rootpkg \
  && mkdir /runtime-apks \
  && find /packages -type f \( -name 'curl-[0-9]*.apk' -o -name 'libcurl-[0-9]*.apk' \) -exec cp '{}' /runtime-apks/ \;

FROM curl-packages AS curl-checks
CMD ["abuild", "-F", "check"]

FROM apk-builder AS imagequant-packages
COPY docker/packages/libimagequant /build/libimagequant
WORKDIR /build/libimagequant
RUN abuild -F -r -P /packages \
  && mkdir /runtime-apks \
  && find /packages -type f -name 'libimagequant-[0-9]*.apk' -exec cp '{}' /runtime-apks/ \;

FROM scratch AS security-packages
COPY --from=apk-builder /package-keys/ /keys/
COPY --from=curl-packages /runtime-apks/ /packages/
COPY --from=imagequant-packages /runtime-apks/ /packages/

# pre-build stage
FROM node:24.22.1-alpine3.24 AS node
FROM ruby:3.4.12-alpine3.24 AS pre-builder

ARG NODE_VERSION="24.22.1"
ARG PNPM_VERSION="10.2.0"
ENV NODE_VERSION=${NODE_VERSION}
ENV PNPM_VERSION=${PNPM_VERSION}

# ARG default to production settings
# For development docker-compose file overrides ARGS
ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}
ENV BUNDLER_VERSION=2.5.16

ARG RAILS_SERVE_STATIC_FILES=true
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ARG NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"
ENV NODE_OPTIONS=${NODE_OPTIONS}

ENV BUNDLE_PATH="/gems"

RUN apk upgrade --no-cache && apk add --no-cache \
  openssl \
  tar \
  build-base \
  tzdata \
  postgresql-dev \
  postgresql-client \
  git \
  curl \
  xz \
  && mkdir -p /var/app \
  && gem install bundler -v "$BUNDLER_VERSION"

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN npm install -g pnpm@${PNPM_VERSION}

RUN echo 'export PNPM_HOME="/root/.local/share/pnpm"' >> /root/.shrc \
  && echo 'export PATH="$PNPM_HOME:$PATH"' >> /root/.shrc \
  && export PNPM_HOME="/root/.local/share/pnpm" \
  && export PATH="$PNPM_HOME:$PATH" \
  && pnpm --version

# Persist the environment variables in Docker
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

WORKDIR /app

COPY Gemfile Gemfile.lock ./

# natively compile grpc and protobuf to support alpine musl (dialogflow-docker workflow)
# https://github.com/googleapis/google-cloud-ruby/issues/13306
# adding xz as nokogiri was failing to build libxml
# https://github.com/chatwoot/chatwoot/issues/4045
RUN apk update && apk add --no-cache build-base musl ruby-full ruby-dev gcc make musl-dev openssl openssl-dev g++ linux-headers xz vips
RUN --mount=type=bind,from=security-packages,target=/tmp/security-packages \
  apk add --no-network --keys-dir /tmp/security-packages/keys /tmp/security-packages/packages/*.apk
RUN bundle config set --local force_ruby_platform true

# Do not install development or test gems in production
RUN if [ "$RAILS_ENV" = "production" ]; then \
  bundle config set without 'development test'; bundle install -j 4 -r 3; \
  else bundle install -j 4 -r 3; \
  fi

COPY package.json pnpm-lock.yaml ./
RUN pnpm i

COPY . /app

# creating a log directory so that image wont fail when RAILS_LOG_TO_STDOUT is false
# https://github.com/chatwoot/chatwoot/issues/701
RUN mkdir -p /app/log

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
  SECRET_KEY_BASE=precompile_placeholder RAILS_LOG_TO_STDOUT=enabled bundle exec rake assets:precompile \
  && rm -rf spec test tests node_modules tmp/cache; \
  fi

# Generate .git_sha file with current commit hash
RUN git rev-parse HEAD > /app/.git_sha

# Remove unnecessary files
RUN rm -rf /gems/ruby/3.4.0/cache/*.gem \
  && find /gems/ruby/3.4.0/gems/ \( -name "*.c" -o -name "*.o" \) -delete \
  && rm -rf .git \
  && rm .gitignore

# final build stage
FROM ruby:3.4.12-alpine3.24

ARG NODE_VERSION="24.22.1"
ARG PNPM_VERSION="10.2.0"
ENV NODE_VERSION=${NODE_VERSION}
ENV PNPM_VERSION=${PNPM_VERSION}

ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}
ENV BUNDLER_VERSION=2.5.16

ARG EXECJS_RUNTIME="Disabled"
ENV EXECJS_RUNTIME=${EXECJS_RUNTIME}

ARG RAILS_SERVE_STATIC_FILES=true
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}

ARG BUNDLE_FORCE_RUBY_PLATFORM=1
ENV BUNDLE_FORCE_RUBY_PLATFORM=${BUNDLE_FORCE_RUBY_PLATFORM}

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ENV BUNDLE_PATH="/gems"

RUN --mount=type=bind,from=security-packages,target=/tmp/security-packages \
  apk upgrade --no-cache && apk add --no-cache \
  libstdc++ \
  openssl \
  tzdata \
  postgresql-client \
  vips \
  && apk add --no-network --keys-dir /tmp/security-packages/keys \
    /tmp/security-packages/packages/libcurl-*.apk /tmp/security-packages/packages/libimagequant-*.apk \
  && gem install bundler -v "$BUNDLER_VERSION"

# Restrict libvips to its trusted image loaders when generating variants
ENV VIPS_BLOCK_UNTRUSTED=1

COPY --from=node /usr/local/bin/node /usr/local/bin/

RUN --mount=type=bind,from=node,source=/usr/local/lib/node_modules,target=/tmp/node_modules \
  --mount=type=bind,from=security-packages,target=/tmp/security-packages \
  if [ "$RAILS_ENV" != "production" ]; then \
  cp -a /tmp/node_modules /usr/local/lib/node_modules \
  && apk add --no-cache build-base git imagemagick \
  && apk add --no-network --keys-dir /tmp/security-packages/keys /tmp/security-packages/packages/curl-*.apk \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && npm install -g pnpm@${PNPM_VERSION} \
  && pnpm --version; \
  fi

COPY --from=pre-builder /gems/ /gems/
RUN --mount=type=bind,source=docker/build/update_default_json.rb,target=/tmp/update_default_json.rb \
  ruby /tmp/update_default_json.rb
COPY --from=pre-builder /app /app

# Copy .git_sha file from pre-builder stage
COPY --from=pre-builder /app/.git_sha /app/.git_sha

WORKDIR /app

EXPOSE 3000
