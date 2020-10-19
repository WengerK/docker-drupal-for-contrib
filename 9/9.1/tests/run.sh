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

docker exec "${cid}" drush status | grep -q 'Drupal root    : /opt/drupal/web'
docker exec "${cid}" drush status | grep -q 'Drupal version : 9.1.0-dev'
docker exec "${cid}" drush status | grep -q 'Drush version  : 10.'
docker exec "${cid}" which phpunit | grep -q '/opt/drupal/vendor/bin/phpunit'
docker exec "${cid}" phpunit --version | grep -q 'PHPUnit 9.'
echo "OK"
