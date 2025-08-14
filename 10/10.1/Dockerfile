ARG BASE_IMAGE_TAG=10.1
FROM drupal:${BASE_IMAGE_TAG}-apache

ARG DRUPAL_VER

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV DRUPAL_VER="${DRUPAL_VER}"

WORKDIR /opt/drupal

# Install git and zip library.
# Necessary for some composer operations.
RUN set -eux; \
  \
  apt-get update; \
  apt-get install -y \
    git \
    zip \
    unzip \
  ;

# Install wait-for-it script to be able to check if services are up.
RUN curl -OL https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x wait-for-it.sh && \
    mv wait-for-it.sh /usr/local/bin/wait-for-it

# As of Composer 2.2.0, the allow-plugins option adds a layer of security.
# Some plugin Installer must be authorized. Not allowing it may lead to an instance of Drupal
# installed into the vendor directory.
RUN composer config --no-interaction allow-plugins true

# Install Drupal Dev dependencies such as PHPUnit, Behat-Mink, ...
RUN COMPOSER_MEMORY_LIMIT=-1 composer require --dev drupal/core-dev:~${DRUPAL_VERSION}

# Install Drush.
# Drush will be heavily use to setup a working Drupal environment.
RUN COMPOSER_MEMORY_LIMIT=-1 composer require drush/drush:^11.0.4

# Clean repository.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy a default template for PHPUnit testing.
COPY templates/phpunit.xml /opt/drupal/web/phpunit.xml
