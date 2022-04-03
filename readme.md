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

## Step to Bulid environment
1. Type `./dev.sh` to bring the menu


### Troubleshooting
Error: `Error response from daemon: failed to reach build target frontend in Dockerfile`
For the following error execute the following command
Command: `docker-compose down -v --rmi all --remove-orphans`