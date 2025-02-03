# syntax=docker/dockerfile:1
FROM php

ENV APP_RUNTIME=Runtime\\FrankenPhpSymfony\\Runtime
ENV FRANKENPHP_CONFIG="worker /app/public/index.php"
# We put our apps behind an HTTPS load balancer, so all internal traffic is HTTP port 80
ENV SERVER_NAME=:80

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

RUN mkdir -p /root/.ssh/ /app/var/log/ /app/var/cache/ \
    && ssh-keyscan bitbucket.org > /root/.ssh/known_hosts

COPY --from=composer/composer:2-bin /composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1