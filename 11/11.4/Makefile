DRUPAL_VER ?= 11.4
DRUPAL_VER_MAJOR ?= $(shell echo "${DRUPAL_VER}" | grep -oE '^[0-9]+\.[0-9]+')

BASE_IMAGE_TAG = 11.4

# Architecture used by build/test: a single arch loaded into the local Docker
# image store. Defaults to the host architecture.
HOST_ARCH := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
ARCH_TO_BUILD ?= linux/$(HOST_ARCH)

# Architectures built and pushed as a multi-arch manifest on release.
PLATFORMS ?= linux/amd64,linux/arm64

REPO = wengerk/drupal-for-contrib
NAME = drupal-$(DRUPAL_VER_MAJOR)

TAG ?= $(DRUPAL_VER_MAJOR)

ifneq ($(BASE_IMAGE_STABILITY_TAG),)
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-$(BASE_IMAGE_STABILITY_TAG)
endif

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

BUILD_ARGS = --build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
	--build-arg DRUPAL_VER=$(DRUPAL_VER)

.PHONY: build build-nc test push shell run start stop logs clean release

default: build

build:
	docker buildx build --load -t $(REPO):$(TAG) \
		--platform=$(ARCH_TO_BUILD) \
		$(BUILD_ARGS) \
		./

build-nc:
	docker buildx build --load -t $(REPO):$(TAG) \
		--platform=$(ARCH_TO_BUILD) \
		$(BUILD_ARGS) \
		--no-cache --pull \
		./

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) ./run.sh

# Push the single-arch image built locally by `make build`.
push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

# Build all $(PLATFORMS) and push them as a single multi-arch manifest.
release:
	docker buildx build --push -t $(REPO):$(TAG) \
		--platform=$(PLATFORMS) \
		$(BUILD_ARGS) \
		./
