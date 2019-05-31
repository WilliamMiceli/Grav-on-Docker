FROM nginx:stable-alpine
LABEL maintainer="William Miceli <git@williammiceli.me>"
USER root

ARG GRAV_VERSION

# Install Dependencies Needed For Grav, With Optional Modules To Help With Performance
RUN apk add --no-cache \
    dcron \
    php7 \
    php7-curl \
    php7-dom \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-mbstring \
    php7-openssl \
    php7-pecl-apcu \
    php7-pecl-yaml \
    php7-session \
    php7-simplexml \
    php7-xml \
    php7-zip \
    && (crontab -u nginx -l; echo "* * * * * cd /var/www;/usr/bin/php bin/grav scheduler 1>> /dev/null 2>&1") | crontab -u nginx -

# Install Grav Into The Root Web Directory
RUN mkdir -p /var/www \
    && apk add --no-cache ca-certificates \
    && apk add --no-cache --virtual .install-dependencies unzip wget \
    && wget -P /var/www/ https://github.com/getgrav/grav/releases/download/${GRAV_VERSION}/grav-admin-v${GRAV_VERSION}.zip \
    && unzip -q /var/www/grav-admin-v${GRAV_VERSION}.zip -d /var/www/ \
    && rm /var/www/grav-admin-v${GRAV_VERSION}.zip \
    && mv /var/www/grav-admin/* /var/www/ \
    && rm -rfv /var/www/grav-admin \
    && apk del .install-dependencies \
    && chown -R nginx:nginx /var/www

# Configure NGINX For Grav
ADD https://raw.githubusercontent.com/getgrav/grav/c381bc83040e00c9a8ebe91ac3bda5fe0c217197/webserver-configs/nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/root \/home\/USER\/www\/html/root \/var\/www/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock;/fastcgi_pass unix:\/var\/run\/php-fpm.sock;/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/default.conf \
    && sed -i '23cuser = nginx' /etc/php7/php-fpm.d/www.conf \
    && sed -i '24cgroup = nginx' /etc/php7/php-fpm.d/www.conf \
    && sed -i '47clisten.owner = nginx' /etc/php7/php-fpm.d/www.conf \
    && sed -i '48clisten.group = nginx' /etc/php7/php-fpm.d/www.conf \
    && sed -i '49clisten.mode = 0660' /etc/php7/php-fpm.d/www.conf \
    && sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g' /etc/php7/php-fpm.d/www.conf

COPY /entrypoint.sh /

VOLUME ["/var/www/user"]

EXPOSE 80
CMD ["sh", "/entrypoint.sh"]