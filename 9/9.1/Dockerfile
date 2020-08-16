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

# Add Composer vendors directory to the path.
# So we would be able to run binary without specifying ./vendor/bin/.
ENV PATH /opt/drupal/vendor/bin:$PATH

# Install Drush.
# Drush will be heavily use to setup a working Drupal environment.
RUN COMPOSER_MEMORY_LIMIT=-1 composer require drush/drush:^10.1.1

# Install Drush Launcher
# So we would be able the run drush from any places without being in the Drupal web directory.
RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush

# Update to latest Drupal 9 upgrade.
# @see https://www.drupal.org/docs/upgrading-drupal/upgrading-from-drupal-8-to-drupal-9-or-higher
RUN composer require drupal/core-recommended:^${DRUPAL_VER} drupal/core-composer-scaffold:^${DRUPAL_VER} drupal/core-project-message:^${DRUPAL_VER} --update-with-dependencies --no-update
RUN composer require drupal/core-dev:^${DRUPAL_VER} --dev --update-with-dependencies --no-update

# Perform Drupal 9 installation
RUN COMPOSER_MEMORY_LIMIT=-1 composer update

# Clean repository.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy a default template for PHPUnit testing.
COPY templates/phpunit.xml /var/www/html/phpunit.xml
