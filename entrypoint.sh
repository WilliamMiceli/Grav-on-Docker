#!/bin/sh

echo "[ INFO ] Starting PHP-FPM"
php-fpm7 -D # Background

#echo "[ INFO ] Starting cron"
#crond # Background

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;" # Foreground