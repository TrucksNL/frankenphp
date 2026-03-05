# syntax=docker/dockerfile:1

FROM php

RUN apk add --no-cache \
    acl \
    file \
    gettext \
    git \
    openssh

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

# https://symfony.com/doc/current/performance.html#configure-the-php-realpath-cache
ENV PHP_REALPATH_CACHE_SIZE="4096K"
ENV PHP_REALPATH_CACHE_TTL=600

# https://symfony.com/doc/current/performance.html#configure-opcache-for-maximum-performance
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=256
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=32531
ENV PHP_OPCACHE_MAX_WASTED_PERCENTAGE=5

# https://symfony.com/doc/current/performance.html#don-t-check-php-files-timestamps
# Set to "1" in Dev, "0" in Prod
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0

ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_ENABLE_CLI=1
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER=16
ENV PHP_OPCACHE_PRELOAD="/app/config/preload.php"
ENV PHP_OPCACHE_PRELOAD_USER="www-data"

COPY ./core.ini ./opcache.ini ./realpath.ini /usr/local/etc/php/conf.d/
COPY ./Caddyfile /etc/frankenphp/Caddyfile

RUN mkdir -p /root/.ssh/ /app/var/log/ /app/var/cache/ \
    && ssh-keyscan bitbucket.org > /root/.ssh/known_hosts

ENV FRANKENPHP_CONFIG="worker /app/public/index.php"
# We put our apps behind an HTTPS load balancer, so all internal traffic is HTTP port 80
ENV SERVER_NAME=:80
