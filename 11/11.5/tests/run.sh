#!/usr/bin/env bash
set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if ! [ -x "$(command -v container-structure-test)" ]; then
  echo -n "Install Google Container Structure Tests Framework for ${IMAGE} ..."

  # Check install for Linux or MacOS.
  if [[ $(uname -s) == Linux ]]
  then
      curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 && chmod +x container-structure-test-linux-amd64 && sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
  elif [[ $(uname -s) == Darwin ]]
  then
      curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-darwin-amd64 && chmod +x container-structure-test-darwin-amd64 && sudo mv container-structure-test-darwin-amd64 /usr/local/bin/container-structure-test
  fi
fi

if ! [ -x "$(command -v container-structure-test)" ]; then
  echo 'Error: container-structure-test is not installed.' >&2
  exit 1
fi

echo -n "Running tests for ${IMAGE}..."

cid="$(
	docker run -d "${IMAGE}"
)"
trap "docker rm -vf ${cid} > /dev/null" EXIT

container-structure-test test --image ${IMAGE} --config config.yaml
