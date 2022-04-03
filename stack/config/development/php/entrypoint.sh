#!/bin/bash
set -e

if [ -z "${PHP_SESSION_SAVE_HANDLER}" ]; then
  export PHP_SESSION_SAVE_HANDLER=files
fi

if [ -z "${PHP_SESSION_SAVE_PATH}" ]; then
  export PHP_SESSION_SAVE_PATH=/tmp
fi

if [ -z "${PHP_SEND_MAIL_PATH}" ]; then
  export PHP_SEND_MAIL_PATH=""
fi

# Configuring PHP INI
if [ -f "/usr/local/etc/php/conf.d/custom.ini.template" ]; then
  echo "Creating Custom PHP configurations"
  EXPORT_ENVIRONMENT_VARIABLES='\$PHP_SESSION_SAVE_HANDLER \$PHP_SESSION_SAVE_PATH \$PHP_SEND_MAIL_PATH'
  envsubst "$EXPORT_ENVIRONMENT_VARIABLES" < /usr/local/etc/php/conf.d/custom.ini.template > /usr/local/etc/php/conf.d/custom.ini
fi

# Welcome Message
echo "Default startup script with $@"
exec "$@"