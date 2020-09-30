FROM php:7.4.9-apache

# Install PHP 
RUN apt-get update && apt-get upgrade -y \
    g++ \
    libc-client-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    libpq-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng-dev \
    libmemcached-dev \
    libssl-dev \
    libssl-doc \
    libsasl2-dev \
    zlib1g-dev \
    && docker-php-ext-install \
    bz2 \
    iconv \
    mysqli \
    pdo_mysql \
    soap \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && yes '' | pecl install imagick && docker-php-ext-enable imagick \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && apt-get autoremove -y --purge \
    && apt-get clean \
    && rm -Rf /tmp/* \
    && a2enmod rewrite;

# Zip extension
# https://stackoverflow.com/a/48700777/1153296
RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip
