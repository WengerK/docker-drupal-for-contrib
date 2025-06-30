# Drupal Docker Container for Contributions

[![Build Status](https://github.com/WengerK/docker-drupal-for-contrib/actions/workflows/container-structure-test.yml/badge.svg)](https://github.com/WengerK/docker-drupal-for-contrib/actions/workflows/container-structure-test.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/wengerk/drupal-for-contrib.svg)](https://hub.docker.com/r/wengerk/drupal-for-contrib)
[![Docker Stars](https://img.shields.io/docker/stars/wengerk/drupal-for-contrib.svg)](https://hub.docker.com/r/wengerk/drupal-for-contrib)

Many Drupal Docker images exists on [Docker Hub](https://hub.docker.com/search?q=drupal&type=image). So why another image ?
All of those images serve the same purpose, **integrate Docker into a complete Drupal project**. 

This image is way different as we don't want to solve the Docker integration with Drupal but give a **solution to setup a Docker on Contributions modules or themes**.

I see way too many developers creating awesome modules and struggling to test them by having to bootstrap a complete clean Drupal 8/9/10/11 environment and symlinks the custom modules/themes inside it.
With this Docker image, I want to highly simplify this process by having a containerized Drupal 8/9 used for manual or automated testing of modules/themes Contributions projects.

## Docker Images

❗For better reliability we release images with stability tags (`wengerk/drupal-for-contrib:9.X`) which **does not correspond** to [git tags](https://github.com/wengerk/docker-drupal-for-contrib/releases). We strongly recommend using images only with stability tags. 

Overview:

* All images based on the [official Drupal Docker](https://github.com/docker-library/drupal) maintained by: the Docker Community.
* [Travis CI builds](https://travis-ci.com/github/WengerK/docker-drupal-for-contrib) 
* [Docker Hub](https://hub.docker.com/r/wengerk/drupal-for-contrib)

| Supported tags and respective `Dockerfile` links                                                             | Drupal   |
|--------------------------------------------------------------------------------------------------------------|----------|
| `11.3` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/11/11.3/Dockerfile) | 11.3-dev |
| `11.2` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/11/11.2/Dockerfile) | 11.2.x  |
| `11.1` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/11/11.1/Dockerfile) | 11.1.x   |
| `11.0` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/11/11.0/Dockerfile) | 11.0.x   |
| `10.5` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/10/10.5/Dockerfile) | 10.5.x   |
| `10.4` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/10/10.4/Dockerfile) | 10.4.x   |
| `10.3` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/10/10.3/Dockerfile) | 10.3.x   |
| `10.2` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/10/10.2/Dockerfile) | 10.2.x   |
| `10.1` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/10/10.1/Dockerfile) | 10.1.x   |
| `10.0` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/10/10.0/Dockerfile) | 10.0.x   |
| `9.5` [_(Dockerfile)_](https://github.com/wengerk/docker-drupal-for-contrib/tree/master/9/9.5/Dockerfile)    | 9.5.x    |

## Usage in a Drupal Contribution Modules/Themes

1. Create a `Dockerfile` file at the root level of your repository

    ```
    ARG BASE_IMAGE_TAG=10.5
    FROM wengerk/drupal-for-contrib:${BASE_IMAGE_TAG}
    ```

2. Create a `docker-compose.yml` file at the root level of your repository

    ```yaml
    services:
    
      drupal:
        build: .
        depends_on:
          - db
        ports:
          - 8888:80
        volumes:
          # Mount the module in the proper contrib module directory.
          - .:/opt/drupal/web/modules/contrib/my_module
        restart: always
    
      db:
        image: mariadb:10.6
        environment:
          MYSQL_USER: drupal
          MYSQL_PASSWORD: drupal
          MYSQL_DATABASE: drupal
          MYSQL_ROOT_PASSWORD: root
        restart: always
    ```
    
    Update the mounted `volume` name to match your custom module name.

3. Run Docker

```shell
$ docker-compose build --pull --build-arg BASE_IMAGE_TAG=10.5 drupal
$ docker-compose up -d drupal
# wait on Docker to be ready, especially MariaDB that takes many seconds to be up before install.
$ docker-compose exec -u www-data drupal drush site-install standard --db-url="mysql://drupal:drupal@db/drupal" --site-name=Example -y
```

4. Run PHPUnit testing

```shell
docker-compose exec -u www-data drupal phpunit --no-coverage --group=my_module
```

## Travis Integration example

1. Create a `.travis.yml` file at the root level of your repository

```yaml
language: php

services:
  - docker

env:
  global:
    # The module name to be mounted and tested in the Docker.
    - MODULE_NAME="my_module"

jobs:
  include:
    - name: D8.9
      env: BASE_IMAGE_TAG="8.9"
    - name: D9.0
      env: BASE_IMAGE_TAG="9.0"
    - name: D10.0
      env: BASE_IMAGE_TAG="10.0"
    - name: D11.0
      env: BASE_IMAGE_TAG="11.0"

before_install:
  - docker-compose build --pull --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG} drupal
  - docker-compose up -d drupal
  # wait on Docker to be ready, especially MariaDB that takes many seconds to be up.
  - docker-compose exec drupal wait-for-it drupal:80 -t 60
  - docker-compose exec drupal wait-for-it db:3306 -t 60

before_script:
  - docker-compose exec -u www-data drupal drush site-install standard --db-url="mysql://drupal:drupal@db/drupal" --site-name=Example -y

script:
  - docker-compose exec -u www-data drupal phpunit --no-coverage --group=${MODULE_NAME} --configuration=/opt/drupal/web/phpunit.xml
```

## Github Actions Integration example

```yaml
name: Continuous integration
on: [push]

jobs:
  tests:
    name: Tests
    runs-on: ubuntu-latest

    strategy:
      matrix:
        drupal_version: ['8.9', '9.0', '9.1', '10.0', '10.1', '10.2', '11.0']
        module: ['my_module']
        experimental: [ false ]
        include:
          - drupal_version: '10.3'
            module: 'my_module'
            experimental: true
          - drupal_version: '11.1'
            module: 'my_module'
            experimental: true

    steps:
      - uses: actions/checkout@v3
      - run: docker-compose -f docker-compose.yml pull --include-deps drupal
      - name: Build the docker-compose stack
        run: docker-compose -f docker-compose.yml build --pull --build-arg BASE_IMAGE_TAG=${{ matrix.drupal_version }} drupal
        continue-on-error: ${{ matrix.experimental }}
      - name: Run unit tests
        run: docker-compose -f docker-compose.yml run -u www-data drupal phpunit --no-coverage --group=${{ matrix.module }} --configuration=/var/www/html/phpunit.xml
        continue-on-error: ${{ matrix.experimental }}
```
