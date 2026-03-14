#!/bin/bash

NGINX_SITES_DIR="/etc/nginx/sites-enabled"
BASE_DIR="/var/www"
SUPERVISOR_DIR="/etc/supervisor/conf.d"
CRON_FILE="/etc/cron.d/laravel-scheduler"

RUN_USER="www-data"
WORKER_COUNT=2

echo "Updating packages..."
apt update -y

echo "Installing Supervisor if necessary..."
apt install -y supervisor

echo "Resetting scheduler cron file..."
> "$CRON_FILE"

for CONFIG in ${NGINX_SITES_DIR}/*; do

    SITE_NAME=$(basename "$CONFIG")

    if [ "$SITE_NAME" = "default" ]; then
        continue
    fi

    APP_DIR="${BASE_DIR}/${SITE_NAME}"

    if [ ! -f "${APP_DIR}/artisan" ]; then
        echo "Skipping ${SITE_NAME}: not a Laravel project"
        continue
    fi

    echo "Configuring Laravel site: ${SITE_NAME}"

    SUPERVISOR_CONF="${SUPERVISOR_DIR}/${SITE_NAME}-worker.conf"

    cat > "$SUPERVISOR_CONF" <<EOF
[program:${SITE_NAME}-worker]
process_name=%(program_name)s_%(process_num)02d
directory=${APP_DIR}
command=php artisan queue:work --sleep=3 --tries=3 --timeout=90 --memory=128
autostart=true
autorestart=true
user=${RUN_USER}
numprocs=${WORKER_COUNT}
redirect_stderr=true
stdout_logfile=${APP_DIR}/storage/logs/worker.log
stopwaitsecs=3600
stopasgroup=true
killasgroup=true
EOF

    echo "* * * * * ${RUN_USER} cd ${APP_DIR} && php artisan schedule:run >> /dev/null 2>&1" >> "$CRON_FILE"

done

echo "Setting cron permissions..."
chmod 644 "$CRON_FILE"

echo "Reloading Supervisor..."
supervisorctl reread
supervisorctl update

echo "Supervisor status:"
supervisorctl status
