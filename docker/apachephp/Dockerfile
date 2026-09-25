########################################################################################################################
# Platform target for images
########################################################################################################################
ARG BASE_IMAGE_PLATFORM=linux/amd64
ARG DOCKER_IMAGE_TAG=8.5-apache


########################################################################################################################
# Base apache / php image
########################################################################################################################
FROM --platform=${BASE_IMAGE_PLATFORM} php:${DOCKER_IMAGE_TAG} AS apachephp

#~ Some ARGs config
ARG PHP_VERSION=8.5
ARG APP_UID=1000
ARG APP_USER="appuser"
ARG APACHE_USER="www-data"
ARG PATH_APP="/app"

#~ Upgrade the image & use specific php extensions
RUN apt update \
 && apt install -y \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-xml \
        jq \
        unzip

#~ Handle composer for prod
ADD https://getcomposer.org/download/latest-2.x/composer.phar /usr/local/bin/composer

RUN chmod a+rx /usr/local/bin/composer

#~ Copy vhost config
COPY etc/vhost.conf /etc/apache2/sites-available/application.conf

#~ Enable some apache mods + set
RUN a2enmod rewrite \
 && a2enmod headers \
 && rm -f /etc/apache2/sites-enabled/000-default.conf \
 && ln -s /etc/apache2/sites-available/application.conf /etc/apache2/sites-enabled/000-application.conf \
 && install -d -m 0755 -o ${APACHE_USER} -g ${APACHE_USER} ${PATH_APP} \
 && chmod +x /root/  \
 && chown ${APACHE_USER}: /root/apache.sh \
 && chown -R ${APACHE_USER}: /var/log/apache2 /var/run/apache2 \
 && sed -i "s/var\/www/app/g" /etc/apache2/apache2.conf \
 && sed -i "s/Listen 80/Listen 8080/g" /etc/apache2/ports.conf \
 && sed -i "s/:80/:8080/g" /etc/apache2/sites-available/*.conf


########################################################################################################################
# Stage "dev"
########################################################################################################################
FROM apachephp AS dev
# ~ No copy of the code, will be mounted from host

#~ install xdebug + make + clean
RUN apt install -y php${PHP_VERSION}-xdebug make && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#~ Add local user with same UID/GID as host user to avoid permission issues on mounted volumes (generally is 1000) and add it to www-data / app group
RUN useradd --uid ${APP_UID} --groups ${APACHE_USER} ${APP_USER} --create-home

#~ Use apache user
USER ${APACHE_USER}


########################################################################################################################
# Stage "prod"
########################################################################################################################
FROM apachephp AS prod
#~ Copy code into container
COPY . ${PATH_APP}
RUN cd ${PATH_APP}/ \
 && composer install --no-dev --optimize-autoloader --no-interaction --no-scripts \
 && rm -rf var/cache/* \
 && rm -rf var/log/* \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chown --silent --no-dereference --recursive --from=0:0 ${APACHE_USER}:${APACHE_USER} ${PATH_APP} \
 && chmod -R 0755 ${PATH_APP}/var/cache

#~ Use apache user
USER ${APACHE_USER}
