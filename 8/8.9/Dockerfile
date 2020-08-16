ARG BASE_IMAGE_TAG
FROM drupal:${BASE_IMAGE_TAG}-apache

ARG DRUPAL_VER

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

# Install Drupal Dev dependencies such as PHPUnit, Behat-Mink, ...
RUN COMPOSER_MEMORY_LIMIT=-1 composer require --dev drupal/core-dev:~${DRUPAL_VER}

# Install Drush.
# Drush will be heavily use to setup a working Drupal environment.
RUN COMPOSER_MEMORY_LIMIT=-1 composer require drush/drush:^10.1.1

# Install Drush Launcher
# So we would be able the run drush from any places without being in the Drupal web directory.
RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush

# Clean repository.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy a default template for PHPUnit testing.
COPY templates/phpunit.xml /opt/drupal/web/phpunit.xml
