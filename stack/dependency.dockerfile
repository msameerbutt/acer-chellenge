#
# Frontend Image
#
FROM node:17 as app-frontend

LABEL Description="${DOCKER_REGISTRY} node image fork of node:17"
LABEL Vendor="${DOCKER_REGISTRY}"
LABEL Version=1.0

# --------- Setup build default options
ARG NODE_CACHE_BUSTER=1
ARG NODE_ENVIRONMENT=production

#
# PHP Image
#
FROM php:7.4-fpm-alpine as app-php

LABEL Description="${DOCKER_REGISTRY} PHP base image fork of php:7.4-fpm-alpine"
LABEL Vendor="${DOCKER_REGISTRY}"
LABEL Version=1.0

# --------- Setup build default options
ARG PHP_CACHE_BUSTER=1
ARG PHP_ENVIRONMENT=production
ARG PHP_ENABLE_MCRYPT=off
ARG PHP_ENABLE_APCU=off
ARG PHP_ENABLE_EXIF=off
ARG PHP_ENABLE_IMAGICK=off
ARG PHP_ENABLE_LDAP=off
ARG PHP_ENABLE_MEMCACHED=off
ARG PHP_ENABLE_MYSQL=off
ARG PHP_ENABLE_POSTGRESQL=off
ARG PHP_ENABLE_REDIS=off
ARG PHP_ENABLE_AWSCLI=off
ARG PHP_ENABLE_SUPERVISOR=off
ARG PHP_WORK_DIR=/usr/local/www/src

RUN echo -n "With apcu support:          " ; if [[ "${PHP_ENABLE_APCU}" = "on" ]] ;       then echo "Yes"; else echo "No" ; fi && \
    echo -n "With exif support:          " ; if [[ "${PHP_ENABLE_EXIF}" = "on" ]] ;       then echo "Yes"; else echo "No" ; fi && \
    echo -n "With imagick support:       " ; if [[ "${PHP_ENABLE_IMAGICK}" = "on" ]] ;    then echo "Yes"; else echo "No" ; fi && \
    echo -n "With ldap support:          " ; if [[ "${PHP_ENABLE_LDAP}" = "on" ]] ;       then echo "Yes"; else echo "No" ; fi && \
    echo -n "With memcached support:     " ; if [[ "${PHP_ENABLE_MEMCACHED}" = "on" ]] ;  then echo "Yes"; else echo "No" ; fi && \
    echo -n "With mysql support:         " ; if [[ "${PHP_ENABLE_MYSQL}" = "on" ]] ;      then echo "Yes"; else echo "No" ; fi && \
    echo -n "With postgresql support:    " ; if [[ "${PHP_ENABLE_POSTGRESQL}" = "on" ]] ; then echo "Yes"; else echo "No" ; fi && \
    echo -n "With redis support:         " ; if [[ "${PHP_ENABLE_REDIS}" = "on" ]] ;      then echo "Yes"; else echo "No" ; fi && \
    echo -n "With awscli support:        " ; if [[ "${PHP_ENABLE_AWSCLI}" = "on" ]] ;      then echo "Yes"; else echo "No" ; fi && \
    echo -n "With supervisor support:    " ; if [[ "${PHP_ENABLE_SUPERVISOR}" = "on" ]] ;      then echo "Yes"; else echo "No" ; fi

# --------- Install dependancies
RUN apk add --update --no-cache \
        bash \
        curl \
        shadow \
        icu-libs \
        libintl \
        libzip \
        aria2 \
        gettext \
        patch

# --------- Install build dependancies
RUN apk add --update --no-cache --virtual .docker-php-global-dependancies \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        gettext-dev \
        gmp-dev \
        icu-dev \
        oniguruma-dev \
        libxml2-dev \
        ldb-dev \
        libzip-dev \
        autoconf \
        g++ \
        make \
        pcre-dev \
        wget

# --------- Install php extensions
RUN php -m && \
    docker-php-ext-configure bcmath --enable-bcmath && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure gettext && \
    docker-php-ext-configure gmp && \
    docker-php-ext-configure intl --enable-intl && \
    docker-php-ext-configure mbstring --enable-mbstring && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-configure soap && \
    docker-php-ext-configure zip && \
    docker-php-ext-install bcmath \
        gd \
        gettext \
        gmp \
        intl \
        mbstring \
        opcache \
        pcntl \
        soap \
        dom \
        xml \
        zip && \
    php -m

# --------- User Directory Ownership
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data \
    && mkdir -p /home/www-data/.composer/cache \
    && mkdir -p ${PHP_WORK_DIR} \
    && mkdir -p /var/log/php \
    && touch /var/log/php/php_error.log \
    && touch /var/log/php/php-fpm-access.log \
    && touch /var/log/php/php-fpm-error.log \
    && touch /var/log/php/php-cli-error.log \
    && chown -R www-data:www-data /home/www-data ${PHP_WORK_DIR}

# --------- Conditionnal installations
# ENABLE CURL
RUN apk add --update curl-dev && \
    docker-php-ext-install curl && \
    apk del gcc g++ && \
    php -m;

# Enable MCRYPT
RUN if [ "${PHP_ENABLE_MCRYPT}" != "off" ]; then \
      apk add --update libmcrypt-dev && \
      pecl install mcrypt && \
      docker-php-ext-enable mcrypt && \
      php -m; \
    else \
      echo "Skip mcrypt support"; \
    fi

# Enable APCu
RUN if [ "${PHP_ENABLE_APCU}" != "off" ]; then \
      pecl install apcu && \
      docker-php-ext-enable apcu && \
      php -m; \
    else \
      echo "Skip apcu support"; \
    fi

# Enable EXIF
RUN if [ "${PHP_ENABLE_EXIF}" != "off" ]; then \
      docker-php-ext-install exif && \
      docker-php-ext-enable exif && \
      php -m; \
    else \
      echo "Skip Exif support"; \
    fi

# Enable imagick
RUN if [ "${PHP_ENABLE_IMAGICK}" != "off" ]; then \
      apk add --update --no-cache \
          imagemagick \
          imagemagick-libs && \
      apk add --update --no-cache --virtual .docker-php-imagick-dependancies \
          imagemagick-dev && \
      pecl install imagick && \
      docker-php-ext-enable imagick && \
      apk del .docker-php-imagick-dependancies && \
      php -m; \
    else \
      echo "Skip imagemagick support"; \
    fi

# Enable LDAP
RUN if [ "${PHP_ENABLE_LDAP}" != "off" ]; then \
      apk add --update --no-cache \
          libldap && \
      apk add --update --no-cache --virtual .docker-php-ldap-dependancies \
          openldap-dev && \
      docker-php-ext-configure ldap && \
      docker-php-ext-install ldap && \
      apk del .docker-php-ldap-dependancies && \
      php -m; \
    else \
      echo "Skip ldap support"; \
    fi


# Enable Memcached
RUN if [ "${PHP_ENABLE_MEMCACHED}" != "off" ]; then \
      apk add --update --no-cache \
          libevent \
          libmemcached-libs && \
      apk add --update --no-cache --virtual .docker-php-memcached-dependancies \
          cyrus-sasl-dev \
          libevent-dev \
          libmemcached-dev && \
      pecl install memcached && \
      docker-php-ext-enable memcached && \
      apk del .docker-php-memcached-dependancies && \
      php -m; \
    else \
      echo "Skip memcached support"; \
    fi

# Enable MySQL
RUN if [ "${PHP_ENABLE_MYSQL}" != "off" ]; then \
      apk add --update --no-cache --virtual .docker-php-mysql-dependancies \
          mysql-client && \
      docker-php-ext-configure mysqli && \
      docker-php-ext-configure pdo_mysql && \
      docker-php-ext-install mysqli \
      pdo_mysql && \
      apk del .docker-php-mysql-dependancies && \
      php -m; \
    else \
      echo "Skip mysql support"; \
    fi

# Enable PostgreSQL
RUN if [ "${PHP_ENABLE_POSTGRESQL}" != "off" ]; then \
      apk add --update --no-cache \
          libpq && \
      apk add --update --no-cache --virtual .docker-php-postgresql-dependancies \
          postgresql-client \
          postgresql-dev && \
      docker-php-ext-configure pdo_pgsql && \
      docker-php-ext-configure pgsql && \
      docker-php-ext-install pdo_pgsql \
          pgsql && \
      apk del .docker-php-postgresql-dependancies && \
      php -m; \
    else \
      echo "Skip postgresql support"; \
    fi

# Enable Redis
RUN if [ "${PHP_ENABLE_REDIS}" != "off" ]; then \
      pecl install redis && \
      docker-php-ext-enable redis && \
      php -m; \
    else \
      echo "Skip redis support"; \
    fi

# Enable AWSClI
RUN if [ "${PHP_ENABLE_AWSCLI}" != "off" ]; then \
    apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli; \
    else \
      echo "Skip awscli support"; \
    fi

# Enable Supervisor Integration
RUN if [ "${PHP_ENABLE_SUPERVISOR}" != "off" ]; then \
    apk add --no-cache \
        supervisor \
    && mkdir -p /var/log/supervisord \
    && chown -R www-data:www-data /var/log/supervisord; \
    else \
      echo "Skip Supervisor support"; \
    fi

# Big clean
RUN apk del .docker-php-global-dependancies && \
    rm -rf /var/cache/apk/* && \
    docker-php-source delete

# logs and directory
RUN find /var/log -type f -name "*.log" -exec chmod 755 {} \;

# Change Working directory
WORKDIR ${PHP_WORK_DIR}

# Expose port
EXPOSE 9000

# Command
CMD ["php-fpm"]

#
# Nginx Image
#
FROM nginx:1.21.6-alpine as app-nginx

LABEL Description="${DOCKER_REGISTRY} PHP base image fork of nginx:1.21.6-alpine"
LABEL Vendor="${DOCKER_REGISTRY}"
LABEL Version=1.0

# --------- Setup build options
ARG NGINX_WORK_DIR=/var/www

# --------- Rremove Configuration
RUN rm /etc/nginx/conf.d/default.conf

# --------- Working and Start nginx
WORKDIR ${NGINX_WORK_DIR}

# --------- Nginx process
CMD ["nginx", "-g", "daemon off;"]

#
# PHP Image for Developers
#
FROM app-php as app-php-devs

LABEL Description="${DOCKER_REGISTRY} PHP base image fork of app-php"
LABEL Vendor="${DOCKER_REGISTRY}"
LABEL Version=1.0

# --------- Setup build default options
ARG PHP_CACHE_BUSTER=1
ARG PHP_ENVIRONMENT=dev
ARG PHP_WORK_DIR='/usr/local/www/src'
ARG PHP_XDEBUG_VERSION=2.9.2

# --------- Installation of Developer tools
# Dev Tools
RUN apk update && apk add --no-cache \
    vim \
    git && \
    rm -rf /var/cache/apk/*

# Xdebug Support
RUN apk --no-cache add --virtual .build-deps \
        g++ \
        autoconf \
        make && \
    pecl install xdebug-${PHP_XDEBUG_VERSION} && \
    docker-php-ext-enable xdebug && \
    apk del .build-deps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mailhog mhsendmail
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && \
    chmod +x mhsendmail_linux_amd64 && \
    mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

# Composer2
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Deactivate Xdebug
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.deactivated

# Expose port
EXPOSE 9000

# Command
CMD ["php-fpm"]