#
# Frontend Image
#
FROM node:17 as app-frontend

LABEL Description="${DOCKER_REGISTRY} node image fork of node:17"
LABEL Vendor="${DOCKER_REGISTRY}"
LABEL Version=1.0

# --------- Setup build default options
ARG APP_CACHE_BUSTER=1
ARG APP_ENVIRONMENT=production
ARG APP_WORK_DIR=/usr/local/www/src

# Create directory
RUN mkdir -p ${APP_WORK_DIR}

# Copy application files
COPY ./ ${APP_WORK_DIR}/

# Change directory
WORKDIR ${APP_WORK_DIR}

# install node modules
RUN npm install

# Compile CSS & JS
RUN npm run production

# --------- PHP Dependencies
FROM composer:2 as app-vendor

# Setup build options
ARG APP_CACHE_BUSTER=1
ARG APP_ENVIRONMENT=production
ARG APP_WORK_DIR=/usr/local/www/src

# Create directory
RUN mkdir -p ${APP_WORK_DIR}

# Copy application files
COPY ./ ${APP_WORK_DIR}/

# Change directory
WORKDIR ${APP_WORK_DIR}

# Install depdency
RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --no-dev

#
# Application Image
#
FROM alpine:latest as app-code

LABEL Description="${DOCKER_REGISTRY} app image for deployment"
LABEL Vendor="${DOCKER_REGISTRY}"
LABEL Version=1.0

# --------- Setup build default options
ARG APP_CACHE_BUSTER=1
ARG APP_ENVIRONMENT=production
ARG APP_WORK_DIR=/usr/local/www/src

RUN mkdir -p ${APP_WORK_DIR}

# Copy App Content
COPY ./ ${APP_WORK_DIR}/
COPY --from=app-frontend ${APP_WORK_DIR}/public ${APP_WORK_DIR}/public
COPY --from=app-vendor ${APP_WORK_DIR}/vendor ${APP_WORK_DIR}/vendor
COPY --from=app-frontend ${APP_WORK_DIR}/resources ${APP_WORK_DIR}/resources

VOLUME ${APP_WORK_DIR}