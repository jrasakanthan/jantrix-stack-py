GITHUB_USERNAME := jrasakanthan
GITHUB_REPO_NAME := dapz-stack

DOCKER_FILE := Dockerfile.base.python
DOCKER_IMAGE_NAME := dz-base
DOCKER_IMAGE_VERSION := 0.1.1
DOCKER_BASE_TAG := python-3.12
DOCKER_TAG := $(DOCKER_BASE_TAG)-v$(DOCKER_IMAGE_VERSION)
DOCKER_LATEST_TAG := $(DOCKER_BASE_TAG)-latest

.PHONY: stop-containers
stop-containers:
	docker-compose down

.PHONY: remove-containers
remove-containers:
	docker-compose rm -f

.PHONY: ghcr-login
ghcr-login:
	echo $(GHCR_PAT) | docker login ghcr.io -u $(GITHUB_USERNAME) --password-stdin

.PHONY: build-base
build-base:
	docker build -t ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG) -f $(DOCKER_FILE) .

.PHONY: push-base
push-base:
	docker push ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

.PHONY: tag-base-latest
tag-base-latest:
	docker tag ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG) ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_LATEST_TAG)

.PHONY: push-python-base-latest
push-base-latest:
	docker push ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_LATEST_TAG)

.PHONY: build-push-base
build-push-base: build-base push-base tag-base-latest push-base-latest

.PHONY: authservice
authservice:
	docker-compose up --build authservice

.PHONY: authservice-debug
authservice-debug:
	docker-compose up --build authservice-debug

.PHONY: authservice-test
authservice-test:
	docker-compose run --rm --build authservice-test

.PHONY: dapzaccessguard
dapzaccessguard:
	docker-compose run --rm --build dapzaccessguard

.PHONY: dapzaccessguard-test
dapzaccessguard-test:
	docker-compose run --rm --build dapzaccessguard-test

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  help: Show this help message"
	@echo "  ghcr-login: Login to GitHub Container Registry"
	@echo "  build-base: Build the base image"
	@echo "  push-base: Push the base image to GitHub Container Registry"
	@echo "  tag-base-latest: Tag the base image as latest"
	@echo "  push-base-latest: Push the base image with latest tag to GitHub Container Registry"
	@echo "  build-push-base: Build and push the base image to GitHub Container Registry"
	@echo "  authservice: Run the authservice"
	@echo "  authservice-debug: Run the authservice in debug mode"
	@echo "  authservice-test: Run the authservice tests"
	@echo "  dapzaccessguard: Run the dapzaccessguard"
	@echo "  dapzaccessguard-test: Run the dapzaccessguard tests"

.DEFAULT_GOAL := help