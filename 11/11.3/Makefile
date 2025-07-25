DRUPAL_VER ?= 11.3
DRUPAL_VER_MAJOR ?= $(shell echo "${DRUPAL_VER}" | grep -oE '^[0-9]+\.[0-9]+')

BASE_IMAGE_TAG = 11.2
ARCH_TO_BUILD ?= "linux/amd64"

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

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker buildx build -t $(REPO):$(TAG) \
		--platform=${ARCH_TO_BUILD} \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg DRUPAL_VER=$(DRUPAL_VER) \
		./

build-nc:
	docker buildx build -t $(REPO):$(TAG) \
		--platform=${ARCH_TO_BUILD} \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg DRUPAL_VER=$(DRUPAL_VER) \
		--no-cache --pull \
		./

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) ./run.sh

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

release: build push
