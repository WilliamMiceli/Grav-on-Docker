#!/bin/sh

# Copy default "User" directory if none already exist
echo "[ INFO ] Checking for any existing files"
if [ -z `/var/www/user/` ]
then
    echo "No pre-existing files found (New instance)"
    echo "Copying default files into the /var/www/user directory"
    tar xz -f USER.tar.gz -C /
    echo "Default files have been copied successfully"
else
    echo "Pre-existing files found (Existing instance)"
    echo "Not taking any action"
fi

chown -R nginx:nginx /var/www

echo "[ INFO ] Starting PHP-FPM"
php-fpm7 -D # Background

echo "[ INFO ] Starting cron"
crond # Background

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;" # Foreground