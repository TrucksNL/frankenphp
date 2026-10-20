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
    mongodb-stable \
    mysqli \
    opcache \
    pdo_mysql \
    redis-stable \
    sysvsem \
    zip

# Run as www-data: Caddy needs writable data/config dirs.
RUN set -eux; \
    home="$(getent passwd www-data | cut -d: -f6)"; \
    mkdir -p /app/var/log /app/var/cache /data/caddy /config/caddy; \
    chown -R www-data:www-data "$home" /app /data /config

USER www-data

# Same as runtime, plus git and ssh for fetching private dependencies (e.g. composer VCS installs).
FROM runtime AS build

USER root

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt-get update \
    && apt-get -y --no-install-recommends install \
    git \
    openssh-client

# Bitbucket host keys, from https://bitbucket.org/site/ssh (verify against Atlassian's published fingerprints).
# System-wide, so ssh works for any user.
COPY --chmod=644 known_hosts /etc/ssh/ssh_known_hosts

USER www-data
