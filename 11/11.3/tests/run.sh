#!/usr/bin/env bash
set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if ! [ -x "$(command -v container-structure-test)" ]; then
  echo -n "Install Google Container Structure Tests Framework for ${IMAGE} ..."

  # Download the binary matching the host OS (linux/darwin) and arch (amd64/arm64).
  # No darwin-arm64 binary is published: macOS always uses amd64 (Rosetta).
  CST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  CST_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
  if [[ "${CST_OS}" == darwin ]]; then
    CST_ARCH=amd64
  fi
  CST_BIN="container-structure-test-${CST_OS}-${CST_ARCH}"
  curl -LO "https://storage.googleapis.com/container-structure-test/latest/${CST_BIN}" && chmod +x "${CST_BIN}" && sudo mv "${CST_BIN}" /usr/local/bin/container-structure-test
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
