# syntax=docker/dockerfile:1
FROM php

ENV FRANKENPHP_CONFIG="worker /app/public/index.php"
# We put our apps behind an HTTPS load balancer, so all internal traffic is HTTP port 8080
ENV SERVER_NAME=:8080

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt-get update \
    && apt-get -y --no-install-recommends install \
    acl \
    file \
    gettext \
    git \
    openssh-client

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

# Run as www-data: home dir holds SSH known_hosts, Caddy needs writable data/config dirs.
RUN set -eux; \
    home="$(getent passwd www-data | cut -d: -f6)"; \
    mkdir -p "$home/.ssh" /app/var/log /app/var/cache /data/caddy /config/caddy; \
    ssh-keyscan ssh.bitbucket.org > "$home/.ssh/known_hosts"; \
    chown -R www-data:www-data "$home" /app /data /config

USER www-data
