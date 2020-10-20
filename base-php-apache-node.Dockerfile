FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# install apt dependencies
RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
    apt-transport-https \
    ca-certificates \
    openssh-client \
    curl \ 
    dos2unix \
    git \
    gnupg2 \
    dirmngr \
    g++ \	
    jq \
    libedit-dev \
    libfcgi0ldbl \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    # libssl-dev \
    # openssh-client \
    supervisor \
    unzip \
    zip \
    && rm -r /var/lib/apt/lists/*

# Set the locale
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8

# Install Apache
RUN apt-get install -y apache2

# Update the apache2.conf 
RUN sed -i "s/ServerTokens OS/ServerTokens Prod/" /etc/apache2/conf-enabled/security.conf

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log 

# Add the "PHP 7" ppa
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php

RUN apt-get update
RUN apt-get install -y \
    php7.0 \
    php7.0-cli \
    php7.0-fpm \
    php7.0-common \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-zip \
    php7.0-memcached \
    php7.0-gd \
    php7.0-dev \
    php7.0-soap \
    php7.0-bcmath \
    pkg-config

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/cli/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/cli/php.ini

# Install Supervisord
RUN apt-get install -y supervisor

# install node js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Install composer
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

# Cleanup
RUN apt-get clean
RUN rm -rf /etc/apache/sites-enabled

# Allows server env (from docker-compose or cloudformation)
# to be available via dotEnv (and $_SERVER) in php-fpm.
RUN sed -e 's/;clear_env = no/clear_env = no/' -i /etc/php/7.0/fpm/pool.d/www.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
