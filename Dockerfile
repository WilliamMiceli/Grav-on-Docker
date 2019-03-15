FROM nginx:stable

# Version of Grav to install
ARG GRAV_VERSION=1.5.8

# Install dependencies
RUN export LC_ALL=C.UTF-8 && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --no-install-recommends sudo wget unzip && \
    # Install PHP 7.2 and Module Requirements for Grav
    php7.2 \
    php7.2-curl \
    php7.2-gd

ADD https://github.com/krallin/tini/releases/download/v0.13.2/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

# Set user to www-data
RUN mkdir -p /var/www && chown www-data:www-data /var/www
USER www-data

# Install grav
WORKDIR /var/www
RUN wget https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip && \
    unzip grav-admin-v$GRAV_VERSION.zip && \
    rm grav-admin-v$GRAV_VERSION.zip && \
    cd grav-admin && \
    bin/gpm install -f -y admin

# Return to root user
USER root

# Configure nginx with grav
WORKDIR /var/www/grav-admin
RUN cd webserver-configs && \
    sed -i 's/root \/home\/USER\/www\/html/root \/var\/www\/grav-admin/g' nginx.conf && \
    cp nginx.conf /etc/nginx/conf.d/default.conf

# Set the file permissions
RUN usermod -aG www-data nginx

# Run startup script
ADD resources /
ENTRYPOINT [ "/usr/local/bin/tini", "--", "/usr/local/bin/startup.sh" ]