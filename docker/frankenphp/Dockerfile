########################################################################################################################
# Platform target for images. For php 8.3, use tag "php8.3"
########################################################################################################################
ARG BASE_IMAGE_PLATFORM=linux/amd64
ARG DOCKER_IMAGE_TAG=php8.5


########################################################################################################################
# Base image with frankenphp
########################################################################################################################
FROM --platform=${BASE_IMAGE_PLATFORM} dunglas/frankenphp:${DOCKER_IMAGE_TAG} AS frankenphp

#~ Upgrade the image & use specific php extensions
RUN apt update && apt upgrade -y && apt clean && apt install -y unzip git
RUN install-php-extensions \
    apcu \
    curl \
    json \
    mbstring \
	opcache \
	pdo_mysql \
    xml

#~ User and permissions to avoid running as root
ARG APP_USER=appuser

#~ Handle composer for prod
ADD https://getcomposer.org/download/latest-2.x/composer.phar /usr/local/bin/composer

RUN \
    #~ Use "adduser -D ${USER}" for Alpine based distributions
    useradd ${APP_USER}; \
    #~ Allow $USER to execute frankenphp binary
    chown -R ${APP_USER}:${APP_USER} /usr/local/bin/frankenphp; \
    #~ Allow rw for $USER on /data/caddy and /config/caddy
    chown -R ${APP_USER}:${APP_USER} /data/caddy && chown -R ${APP_USER}:${APP_USER} /config/caddy; \
    #~ Make composer executable
    chmod a+rx /usr/local/bin/composer;

#~ FrankenPHP config env var
ENV CADDY_GLOBAL_OPTIONS="auto_https off"
ENV SERVER_NAME=":8080"


########################################################################################################################
# Prod stage
########################################################################################################################
FROM frankenphp AS prod

#~ Copy code into container (using .dockerignore)
COPY --chown=${APP_USER}:${APP_USER} . /app

RUN cd /app && composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

USER ${APP_USER}

########################################################################################################################
# Dev stage
########################################################################################################################
FROM frankenphp AS dev

#~ No copy of the code, will be mounted from host
RUN install-php-extensions \
    xdebug

#USER ${APP_USER}
