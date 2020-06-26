#!/usr/bin/env bash
set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

echo -n "Running tests for ${IMAGE}..."

cid="$(
	docker run -d "${IMAGE}"
)"
trap "docker rm -vf ${cid} > /dev/null" EXIT

docker exec "${cid}" drush status | grep -q 'Drupal root    : /var/www/html'
docker exec "${cid}" drush status | grep -q 'Drupal version : 9.1.0-dev'
docker exec "${cid}" drush status | grep -q 'Drush version  : 10.3.0'
docker exec "${cid}" which phpunit | grep -q '/var/www/html/vendor/bin/phpunit'
docker exec "${cid}" phpunit --version | grep -q 'PHPUnit 8.5.8 by Sebastian Bergmann and contributors.'
echo "OK"
