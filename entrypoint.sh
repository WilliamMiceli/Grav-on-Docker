#!/bin/sh

# Copy default "User" directory if none already exist
echo "[ INFO ] Checking for any existing files"
if [ -z `ls -A /var/www/` ]
then
    echo "[ INFO ] No pre-existing files found (New instance)"
    echo "[ INFO ] Copying default files into the /var/www/user directory"
    tar xz -f /GRAV.tar.gz -C /
    echo "[ INFO ] Default files have been copied successfully"
else
    echo "[ INFO ] Pre-existing files found (Existing instance)"
    echo "[ INFO ] Not taking any action"
fi

echo "[ INFO ] Recursively setting default nginx:nginx permissions on web directory"
chown -R nginx:nginx /var/www

echo "[ INFO ] Starting PHP-FPM"
php-fpm7 -D # Background

echo "[ INFO ] Starting cron"
crond # Background

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;" # Foreground