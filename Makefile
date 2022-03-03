SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META=-build$(shell date +%Y%m%d)
ORG ?= briandowns
PKG ?= github.com/tektoncd/pipeline
SRC ?= github.com/tektoncd/pipeline
TAG ?= v0.33.1

ifneq ($(DRONE_TAG),)
TAG := $(DRONE_TAG)
endif

.PHONY: image-build
image-build:
	docker build \
		--pull \
		--build-arg PKG=$(PKG) \
		--build-arg SRC=$(SRC) \
		--build-arg TAG=$(TAG) \
                --build-arg ARCH=$(ARCH) \
		--tag $(ORG)/hardened-tektoncd-pipeline:$(TAG) \
		--tag $(ORG)/hardened-tektoncd-pipeline:$(TAG)-$(ARCH) \
	.

.PHONY: image-push
image-push:
	docker push $(ORG)/hardened-tektoncd-pipeline:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-tektoncd-pipeline:$(TAG) \
		$(ORG)/hardened-tektoncd-pipeline:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-tektoncd-pipeline:$(TAG)

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-tektoncd-pipeline:$(TAG)
