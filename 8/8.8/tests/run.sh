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
docker exec "${cid}" drush status | grep -q 'Drupal version : 8.8.8'
docker exec "${cid}" drush status | grep -q 'Drush version  : 10.'
docker exec "${cid}" which phpunit | grep -q '/var/www/html/vendor/bin/phpunit'
docker exec "${cid}" phpunit --version | grep -q 'PHPUnit 7.5.20 by Sebastian Bergmann and contributors.'
echo "OK"
