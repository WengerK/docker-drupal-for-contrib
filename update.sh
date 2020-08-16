#!/usr/bin/env bash
set -e

VERSION_TO_UPDATE="all"
D8_LAST_VERSION=$(find ./8/* -maxdepth 1 -prune -type d -exec basename {} \; | sort -n | tail -n 1)
D9_LAST_VERSION=$(find ./9/* -maxdepth 1 -prune -type d -exec basename {} \; | sort -n | tail -n 1)

# Options
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
       echo "update.sh - update Dockerfile and scripts for all versions"
       echo " "
       echo "update.sh [options]"
       echo " "
       echo "options:"
       echo "-h, --help                show brief help"
       echo "-b, --build=VERSION       VERSION is optional, all images are build by default; set a VERSION like 'drupal-9.1'"
       echo "--publish=VERSION         set a VERSION like 'drupal-9.1' or 'all'; publish also build images"
       echo "-t, --test=VERSION        VERSION is optional, all images are test by default; set a VERSION like 'drupal-9.1'; test also build images"
       echo "--clean                   clean all local tags of the image"
       exit 0
       ;;
    -b|--build*)
      VERSION_TO_BUILD="${1#*=}"
      if [ "$1" = "--build" ] || [ "$1" = "-b" ]; then
        VERSION_TO_BUILD="all"
      fi
      VERSION_TO_UPDATE=$VERSION_TO_BUILD
      ;;
    --publish=*)
      VERSION_TO_PUBLISH="${1#*=}"
      if [ -z "$VERSION_TO_PUBLISH" ]; then
        echo "VERSION to publish must be set"
        exit 1
      fi
      VERSION_TO_BUILD=$VERSION_TO_PUBLISH
      VERSION_TO_UPDATE=$VERSION_TO_PUBLISH
      ;;
    -t|--test*)
      VERSION_TO_TEST="${1#*=}"
      if [ "$1" = "--test" ] || [ "$1" = "-t" ]; then
        VERSION_TO_TEST="all"
      fi
      VERSION_TO_BUILD=$VERSION_TO_TEST
      ;;
    --clean)
      if [ ! -z "$(docker images | grep wengerk/drupal-for-contrib | tr -s ' ' | cut -d ' ' -f 2 | grep -v '<none>')" ]; then
        docker images | grep wengerk/drupal-for-contrib | tr -s ' ' | cut -d ' ' -f 2 | grep -v '<none>' | xargs -I {} docker rmi wengerk/drupal-for-contrib:{}
      fi
      echo "** images cleanded"
      exit 0
      ;;
  esac
  shift
done

# functions

function build {
  (
    set -e
    TAG=$2

    echo "** build wengerk/drupal-for-contrib:$TAG"
    cd ./$1/$2/
    [[ -f ./Makefile ]] && make
  )
}

function test {
  (
    set -e
    TAG=$2

    echo "** test wengerk/drupal-for-contrib:$TAG"
    cd ./$1/$2/
    [[ -f ./Makefile ]] && make test
  )
}

function publish {
  (
    set -e
    TAG=$2

    echo "** publish wengerk/drupal-for-contrib:$TAG"
    cd ./$1/$2/
    [[ -f ./Makefile ]] && make release
  )
}

function process {
  drupalMajorVersion=$1
  drupalVersion=$2

  # build docker image(s) if required.
  if [ "$VERSION_TO_BUILD" = "all" ] || [ "$VERSION_TO_BUILD" = "$drupalVersion" ]; then
      build $drupalMajorVersion $drupalVersion
  fi

  # test docker image(s) if required.
  if [ "$VERSION_TO_TEST" = "all" ] || [ "$VERSION_TO_TEST" = "$drupalVersion" ]; then
      test $drupalMajorVersion $drupalVersion
  fi

  # publish docker image(s) if required.
  if [ "$VERSION_TO_PUBLISH" = "all" ] || [ "$VERSION_TO_PUBLISH" = "$drupalVersion" ]; then
    publish $drupalMajorVersion $drupalVersion
  fi
}

# Go through versions.
for drupalMajorVersion in `find ./* -maxdepth 1 -prune -type d -exec basename {} \; | sort -n`; do
  for drupalVersion in `find ./$drupalMajorVersion/* -maxdepth 1 -prune -type d -exec basename {} \; | sort -n`; do
    process $drupalMajorVersion $drupalVersion
  done
done
