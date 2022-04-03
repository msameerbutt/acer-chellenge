# PHP Dev Environment Setup

This is a dev environment for PHP web development

## Prerequisites
- Docker
- Git

## Main Tech Stack
- PHP FPM 7.4.16
- nginx:1.21.6
- Node 17
- Composer 2.0
- mailhog:latest
- redis:6.2

## Step to build dev environment
1. Create .env file from .env.example
1. Modify the .env file if require
1. From root directory execute `docker-compose build`, it will take 15-30 minutes
1. From root directory execute `docker-compose up -d` to run the entire stack


## Laravel 9 Sample Application (optional)
Create the [laravel application](https://www.positronx.io/laravel-custom-authentication-login-and-registration-tutorial/) from this tutorial.
The application already included within `src/` folder.

1. Create Laravel App: Execute the following command from the root
```
docker-compose exec php composer create-project --prefer-dist laravel/laravel app
```
1. Install laravel UI
```
docker-compose exec php composer require laravel/ui
```
1. After Composer installation run artisan command to generate scaffolding.
```
docker-compose exec php /usr/local/www/src/artisan ui bootstrap
docker-compose exec php /usr/local/www/src/artisan ui vue
docker-compose exec php /usr/local/www/src/artisan ui react
docker-compose exec php /usr/local/www/src/artisan ui bootstrap --auth
docker-compose exec php /usr/local/www/src/artisan ui vue --auth
docker-compose exec php /usr/local/www/src/artisan ui react --auth
```
1. Connect to Database: Create `/src/.env` file from `/src/.env.example`
1. Restart all containers
1. Create Laravel App: Execute the following command from the root to create necessary tables.
```
docker-compose exec php /usr/local/www/src/artisan migrate
```
1. Install npm
```
docker-compose exec node npm install
docker-compose exec node npm run development
```
1. Create Laravel App: Execute the following command from the root to create necessary tables.
```
docker-compose exec php /usr/local/www/src/artisan optimize:clear
```

### Important URLs:
1. Application URL: https://localhost
2. Mailhog URL: http://localhost:8025

## Laravel 9 Container based deployment
1. Execute from Root `docker-compose -f docker-compose.deploy.yml build`
2. Once Docker image is ready Push the docker app image to the target repository