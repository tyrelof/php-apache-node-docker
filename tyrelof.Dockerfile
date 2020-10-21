FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

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
    # libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpq-dev \
    # libssl-dev \
    # openssh-client \
    supervisor \
    unzip \
    zip \
    # install apache2
    apache2 \
    # install apache2
    # redis-server \
    # install php 7
    libapache2-mod-php7.0 \
    php7.0-cli \
    php7.0-json \
    php7.0-curl \
    php7.0-fpm \
    php7.0-gd \
    php7.0-ldap \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-soap \
    php7.0-sqlite3 \
    php7.0-xml \
    php7.0-zip \
    php7.0-mcrypt \
    php7.0-intl \
    php-imagick \
    php-xdebug \
    # install tools
    vim \
    graphicsmagick \
    imagemagick \
    ghostscript \
    mysql-client \
    iputils-ping \
    apt-utils \
    locales

# enable mods
RUN a2enmod rewrite expires headers proxy_fcgi setenvif 
RUN a2enconf php7.0-fpm 

# start php 7 fpm
RUN service php7.0-fpm start

# modify redis server
# RUN sed -i -e "s/daemonize yes/daemonize no/g" /etc/redis/redis.conf

# install supervisord
RUN apt-get install -y supervisor

# install node js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# install composer
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

# set locales
# RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8

# cleanup
RUN apt-get clean
RUN rm -rf /etc/apache/sites-enabled
RUN rm -r /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]