FROM nginx:1.14.2
USER root

# Version of Grav to install
ARG GRAV_VERSION=1.5.10

# Install PHP and modules needed for Grav, with optional modules to help with performance
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

# Install Grav into the root web directory
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

# Configure NGINX for Grav
ADD https://raw.githubusercontent.com/getgrav/grav/fb20b58369d5e0140a4fa6da06edf8f40412f7bf/webserver-configs/nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/root \/home\/USER\/www\/html/root \/var\/www/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/default.conf
    && usermod -aG www-data nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]