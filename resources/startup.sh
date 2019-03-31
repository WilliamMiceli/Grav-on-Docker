#!/bin/sh

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;"

echo "[ INFO ] Starting PHP-FPM"
service php7.0-fpm start