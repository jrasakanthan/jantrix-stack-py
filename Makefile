include .env

.PHONY: help stop-containers remove-containers stop-all-containers remove-all-containers remove-all-images remove-all-volumes remove-all-networks ghcr-login build-base push-base tag-base-latest push-base-latest build-push-base build-db

DOCKER_BASE_TAG := $(DOCKER_TECHNOLOGY)-$(DOCKER_TECHNOLOGY_VERSION)
ifneq ($(strip $(DOCKER_ENVIRONMENT)),)
	DOCKER_BASE_TAG := $(DOCKER_BASE_TAG)-$(DOCKER_ENVIRONMENT)
endif

DOCKER_TAG := $(DOCKER_BASE_TAG)-v$(DOCKER_IMAGE_VERSION)
DOCKER_LATEST_TAG := $(DOCKER_BASE_TAG)-latest
DOCKER_FILE_PATH := ./dockerfiles/$(DOCKER_TECHNOLOGY)
DOCKER_FILE := $(DOCKER_FILE_PATH)/$(DOCKER_ENVIRONMENT)/Dockerfile

stop-containers:
	docker compose down

remove-containers:
	docker compose rm -f

stop-all-containers:
	docker stop $(shell docker ps -aq) || true

remove-all-containers: stop-all-containers
	docker rm $(shell docker ps -aq) || true

remove-all-images:
	docker rmi $(shell docker images -q) || true

remove-all-volumes:
	docker volume rm $(shell docker volume ls -q) || true

remove-all-networks:
	docker network rm $(shell docker network ls -q) || true

ghcr-login:
	echo $(GHCR_PAT) | docker login ghcr.io -u $(GITHUB_USERNAME) --password-stdin

build-base:
	docker build --no-cache -t ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG) -f $(DOCKER_FILE) .

push-base:
	docker push ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)


tag-base-latest:
	docker tag ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG) ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_LATEST_TAG)

push-base-latest:
	docker push ghcr.io/$(GITHUB_USERNAME)/$(GITHUB_REPO_NAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_LATEST_TAG)

build-push-base: ghcr-login build-base push-base tag-base-latest push-base-latest

start-db:
	docker compose up --build -d postgres

stop-db:
	docker compose down

build-db:
	docker compose build --no-cache postgres

start-all:
	docker compose up --build -d

stop-all:
	docker compose down

create-network:
	docker network create dapperzen

create-rest-api:
	docker compose up --build -d rest-api
# ----------------------------------------------
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

.DEFAULT_GOAL := help