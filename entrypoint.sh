#!/bin/sh

echo "[ INFO ] Starting PHP-FPM"
php-fpm7 -D

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;"