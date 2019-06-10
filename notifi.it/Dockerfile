FROM php:7.1-fpm

EXPOSE 1203

ENV COMPOSER_VERSION 1.8.5

RUN apt update && apt install -y git cmake

# Install zmq
RUN apt-get install -y -qq libzmq3-dev
RUN pecl install zmq-beta && docker-php-ext-enable zmq

# Install Composer
# see https://github.com/RobLoach/docker-composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php

ADD socket /socket
ADD public_html/functions.php /socket/functions.php
WORKDIR /socket

RUN docker-php-ext-install mysqli

RUN composer require cboden/ratchet
RUN composer require React/ZMQ

# run socket
CMD php start.php