#!/bin/sh

echo "[ INFO ] Starting PHP-FPM"
service php7.0-fpm start

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;"