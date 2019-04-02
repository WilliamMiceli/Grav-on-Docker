FROM nginx:1.15.10-alpine
USER root

# Version Of Grav To Install
ARG GRAV_VERSION=1.5.10

# Install PHP And Modules Needed For Grav, With Optional Modules To Help With Performance
RUN apk add --no-cache \
    php7 \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-mbstring \
    php7-pecl-apcu \
    php7-pecl-yaml \
    php7-xml \
    php7-zip

# Install Grav Into The Root Web Directory
RUN mkdir -p /var/www \
    && apk add --no-cache ca-certificates \
    && apk add --no-cache --virtual .build-deps unzip wget \
    && wget -P /var/www/ https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip \
    && unzip -q /var/www/grav-admin-v$GRAV_VERSION.zip -d /var/www/ \
    && rm /var/www/grav-admin-v$GRAV_VERSION.zip \
    && mv /var/www/grav-admin/* /var/www/ \
    && rm -rfv /var/www/grav-admin \
    && apk del .build-deps \
    && addgroup -g 82 -S www-data \
    && adduser -u 82 -D -S -G www-data www-data \
    && chown -R www-data:www-data /var/www

# Configure NGINX For Grav
ADD https://raw.githubusercontent.com/getgrav/grav/c381bc83040e00c9a8ebe91ac3bda5fe0c217197/webserver-configs/nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/root \/home\/USER\/www\/html/root \/var\/www/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/www-data:x:1000:www-data/www-data:x:1000:www-data,nginx/g' /etc/group \
    && sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php\/php7.2-fpm.sock/g' /etc/php7/php-fpm.d/www.conf

# Include Startup Script
COPY /resources/ /resources/

EXPOSE 80
CMD ["sh", "/resources/startup.sh"]