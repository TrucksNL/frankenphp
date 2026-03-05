# syntax=docker/dockerfile:1

FROM php

WORKDIR /app

COPY composer.* symfony.* ./

RUN --mount=type=bind,from=composer/composer:2-bin,source=/composer,target=/usr/local/bin/composer \
    set -eux; \
    PHP_OPCACHE_PRELOAD="" \
	composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

COPY . ./

RUN --mount=type=bind,from=composer/composer:2-bin,source=/composer,target=/usr/local/bin/composer \
    set -eux; \
	mkdir -p var/cache var/log var/share; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	composer dump-env prod; \
	composer run-script --no-dev post-install-cmd; \
	chmod +x bin/console; \
    sync;
