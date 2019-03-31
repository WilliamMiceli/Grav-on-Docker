FROM nginx:1.14.2
USER root

# Version Of Grav To Install
ARG GRAV_VERSION=1.5.10

# Install PHP And Modules Needed For Grav, With Optional Modules To Help With Performance
RUN apt-get update && apt-get install -y --no-install-recommends \
    php \
    php-apcu \
    php-curl \
    php-fpm \
    php-gd \
    php-mbstring \
    php-xml \
    php-yaml \
    php-zip \
    && rm -rf /var/lib/apt/lists/*

# Install Grav Into The Root Web Directory
WORKDIR /var/www
RUN mkdir -p /var/www \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates unzip wget \
    && wget https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip \
    && unzip grav-admin-v$GRAV_VERSION.zip \
    && rm grav-admin-v$GRAV_VERSION.zip \
    && mv grav-admin/* /var/www/ \
    && rm -rfv grav-admin \
    && apt-get purge -y unzip wget \
    && rm -rf /var/lib/apt/lists/* \
    && chown -R www-data:www-data /var/www

# Configure NGINX For Grav
ADD https://raw.githubusercontent.com/getgrav/grav/fb20b58369d5e0140a4fa6da06edf8f40412f7bf/webserver-configs/nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/root \/home\/USER\/www\/html/root \/var\/www/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/default.conf \
    && usermod -aG www-data nginx

# Include Startup Script
COPY /resources/ /resources/

EXPOSE 80
CMD ["sh", "/resources/startup.sh"]