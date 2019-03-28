FROM nginx:stable
USER root

# Version of Grav to install
ARG GRAV_VERSION=1.5.10

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Install PHP and Modules Required for Grav
    php \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
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
    && apt-get remove -y ca-certificates unzip wget \
    && rm -rf /var/lib/apt/lists/* \
    && chown www-data:www-data /var/www

# Configure nginx with grav
WORKDIR /var/www/grav-admin
RUN cd webserver-configs \
    && sed -i 's/root \/home\/USER\/www\/html/root \/var\/www\/grav-admin/g' nginx.conf \
    && cp nginx.conf /etc/nginx/conf.d/default.conf

# Set the file permissions
RUN usermod -aG www-data nginx

# Run startup script
ADD resources /

EXPOSE 80
STOPSIGNAL SIGTERM
# ENTRYPOINT [ "--" ]
# Temporarily removed , "/usr/local/bin/startup.sh"
CMD ["nginx", "-g", "daemon off;"]