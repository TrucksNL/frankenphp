FROM php

# We put our HTTPS apps behind a load balancer, so all internal traffic is HTTP port 80
ENV SERVER_NAME=:80

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

RUN mkdir -p /root/.ssh/ /app/var/log/ /app/var/cache/ \
    && ssh-keyscan bitbucket.org > /root/.ssh/known_hosts

COPY --from=composer/composer:2-bin /composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
