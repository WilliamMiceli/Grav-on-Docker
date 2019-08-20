#!/bin/sh

# Return TRUE if specified directory is empty
directory_empty() {
    [ -z "$(ls -A "$1/")" ]
}

# Copy Grav 'user' files into /var/www/user if no files are already present
echo "[ INFO ] Checking for any existing 'user' files"
if directory_empty "var/www/user"
then
    echo "[ INFO ] No pre-existing 'user' files found (New instance)"
    echo "[ INFO ] Copying default Grav 'user' files into /var/www/user"
    cp -Ru /usr/src/grav/user/* /var/www/user
    echo "[ INFO ] Default 'user' files have been copied successfully"
else
    echo "[ INFO ] 'user' directory not empty (Pre-existing instance):"
    ls -A /var/www/user/ | cat -
    echo "[ INFO ] No 'user' files will be copied"
fi

echo "[ INFO ] Recursively setting default nginx:nginx permissions on web directory"
chown -R nginx:nginx /var/www

echo "[ INFO ] Starting PHP-FPM"
php-fpm7 -D # Background

echo "[ INFO ] Starting cron"
crond # Background

echo "[ INFO ] Starting nginx"
nginx -g "daemon off;" # Foreground
