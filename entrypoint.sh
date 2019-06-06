#!/bin/sh

# Copy default "User" directory if none already exist
echo "[ INFO ] Checking if the /user/data "
if [ -e /var/www/user/data ]
then
    echo "True"
else
    echo "False"
fi

chown -R nginx:nginx /var/www

echo "[ INFO ] Starting PHP-FPM"
php-fpm7 -D # Background

echo "[ INFO ] Starting cron"
crond # Background

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;" # Foreground