# General release info
APP_NAME                = privoxy-scratch
DOCKER_ACCOUNT          = boeboe
VERSION                 = 4.0.0
PLATFORMS               = linux/amd64,linux/arm64,linux/arm/v7
BINARIES_DIR 						= binaries

# HELP
# This will output the help for each task
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

#### DOCKER TASKS ###

build: ## Build the container
	docker buildx build ${DOCKER_BUILD_ARGS} \
		--platform $(PLATFORMS) \
		--build-arg PRIVOXY_VERSION=$(VERSION) \
		-t $(DOCKER_ACCOUNT)/$(APP_NAME):$(VERSION) \
		-t $(DOCKER_ACCOUNT)/$(APP_NAME):latest \
		--load .

build-nc: ## Build the container without caching
	docker buildx build ${DOCKER_BUILD_ARGS} \
		--platform $(PLATFORMS) \
		--no-cache \
		--build-arg PRIVOXY_VERSION=$(VERSION) \
		-t $(DOCKER_ACCOUNT)/$(APP_NAME):$(VERSION) \
		-t $(DOCKER_ACCOUNT)/$(APP_NAME):latest \
		--load .

run: ## Run container
	docker run --name="$(APP_NAME)" $(DOCKER_ACCOUNT)/$(APP_NAME):latest

up: build run ## Build and run container on port configured

stop: ## Stop and remove a running container
	docker stop $(APP_NAME) || true
	docker rm $(APP_NAME) || true

release: build-nc publish ## Make a full release

publish: ## Tag and publish container
	docker buildx build ${DOCKER_BUILD_ARGS} \
		--platform $(PLATFORMS) \
		--build-arg PRIVOXY_VERSION=$(VERSION) \
		-t $(DOCKER_ACCOUNT)/$(APP_NAME):$(VERSION) \
		-t $(DOCKER_ACCOUNT)/$(APP_NAME):latest \
		--push .

extract-binaries: ## Extract privoxy binaries from built images
	mkdir -p $(BINARIES_DIR)
	@for platform in $(shell echo $(PLATFORMS) | tr ',' ' '); do \
		arch=$$(echo $$platform | tr '/' '-'); \
		echo "Extracting privoxy binary for $$platform..."; \
		docker create --name $(APP_NAME)-$$arch --platform=$$platform $(DOCKER_ACCOUNT)/$(APP_NAME):$(VERSION); \
		docker cp $(APP_NAME)-$$arch:/usr/bin/privoxy $(BINARIES_DIR)/privoxy-$(VERSION)-$$arch; \
		docker rm -f $(APP_NAME)-$$arch; \
	done
	@echo "Binaries have been stored in $(BINARIES_DIR)/"
	@cd $(BINARIES_DIR) && shasum -a 256 privoxy-$(VERSION)-* > checksums.txt
	@echo "SHA256 checksums have been stored in $(BINARIES_DIR)/checksums.txt"
