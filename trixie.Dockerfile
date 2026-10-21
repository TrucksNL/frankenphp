# syntax=docker/dockerfile:1
FROM php AS runtime

ENV FRANKENPHP_CONFIG="worker /app/public/index.php"
# We put our apps behind an HTTPS load balancer, so all internal traffic is HTTP port 8080
ENV SERVER_NAME=:8080

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt-get update \
    && apt-get -y --no-install-recommends install \
    acl \
    file \
    gettext

RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    mysqli \
    opcache \
    pdo_mysql \
    sysvsem \
    zip

# excimer (required for Sentry profiling), redis and mongodb are installed with PIE (https://github.com/php/pie)
# instead of PECL, so the build does not depend on pecl.php.net. PIE is only mounted, not kept in the image.
ARG EXCIMER_VERSION=1.2.7
ARG PHPREDIS_VERSION=6.3.0
ARG MONGODB_VERSION=2.5.5
RUN --mount=from=ghcr.io/php/pie:1.5.2-bin,source=/pie,target=/usr/local/bin/pie \
    --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    set -eux; \
    apt-get update; \
    apt-get -y --no-install-recommends install libsasl2-2 libsnappy1v5 libssl3t64 libzstd1 zlib1g; \
    apt-get -y --no-install-recommends install libsasl2-dev libsnappy-dev libssl-dev libzstd-dev zlib1g-dev; \
    pie install "wikimedia/excimer:${EXCIMER_VERSION}"; \
    pie install "phpredis/phpredis:${PHPREDIS_VERSION}"; \
    pie install "mongodb/mongodb-extension:${MONGODB_VERSION}"; \
    apt-get -y purge --auto-remove libsasl2-dev libsnappy-dev libssl-dev libzstd-dev zlib1g-dev; \
    rm -rf /root/.pie /tmp/*

# Run as www-data: Caddy needs writable data/config dirs.
RUN set -eux; \
    home="$(getent passwd www-data | cut -d: -f6)"; \
    mkdir -p /app/var/log /app/var/cache /data/caddy /config/caddy; \
    chown -R www-data:www-data "$home" /app /data /config

USER www-data

# Same as runtime, plus git, ssh and Composer for fetching private dependencies (e.g. composer VCS installs).
# CI overrides the runtime stage with the published runtime image (--build-context runtime=docker-image://...),
# so only the layers below are built.
FROM runtime AS build

USER root

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt-get update \
    && apt-get -y --no-install-recommends install \
    git \
    openssh-client

# Composer, pinned to a minor version; patch releases are picked up on rebuild.
COPY --from=composer/composer:2.10-bin /composer /usr/local/bin/composer

# Bitbucket host keys, from https://bitbucket.org/site/ssh (verify against Atlassian's published fingerprints).
# System-wide, so ssh works for any user.
COPY --chmod=644 known_hosts /etc/ssh/ssh_known_hosts

USER www-data
