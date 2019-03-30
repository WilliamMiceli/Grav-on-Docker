FROM nginx:1.14.2
USER root

# Version of Grav to install
ARG GRAV_VERSION=1.5.10

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Install PHP and modules needed for Grav, with optional modules to help with performance
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

# Install grav
WORKDIR /var/www
RUN mkdir -p /var/www \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates unzip wget \
    && wget https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip \
    && unzip grav-admin-v$GRAV_VERSION.zip \
    && rm grav-admin-v$GRAV_VERSION.zip \
    && cd grav-admin \
    && bin/gpm install -f -y admin \
    && apt-get purge -y wget \
# ca-certificates openssl unzip
    && rm -rf /var/lib/apt/lists/* \
    && chown www-data:www-data /var/www

# Configure NGINX with Grav
ADD https://raw.githubusercontent.com/getgrav/grav/fb20b58369d5e0140a4fa6da06edf8f40412f7bf/webserver-configs/nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/root \/home\/USER\/www\/html/root \/var\/www\/grav-admin/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/default.conf

# Set the file permissions
RUN usermod -aG www-data nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]