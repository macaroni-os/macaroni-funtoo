
BACKEND?=docker
CONCURRENCY?=1
CI_ARGS?=
PACKAGES?=

# Abs path only. It gets copied in chroot in pre-seed stages
export LUET?=/usr/bin/luet
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DESTINATION?=$(ROOT_DIR)/build
COMPRESSION?=zstd
export TREE?=$(ROOT_DIR)/packages
REPO_CACHE?=quay.io/mocaccinocache/funtoo-amd64-cache
export REPO_CACHE
BUILD_ARGS?=--pull --no-spinner
SUDO?=
VALIDATE_OPTIONS?=
ARCH?=amd64

ifneq ($(strip $(REPO_CACHE)),)
	BUILD_ARGS+=--image-repository $(REPO_CACHE)
endif

.PHONY: all
all: deps build

.PHONY: deps
deps:
	@echo "Installing luet"
	go get -u github.com/mudler/luet

.PHONY: clean
clean:
	$(SUDO) rm -rf build/ *.tar *.metadata.yaml

.PHONY: build
build: clean
	mkdir -p $(DESTINATION)
	$(SUDO) $(LUET) build $(BUILD_ARGS) --tree=$(TREE) $(PACKAGES) --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: build-all
build-all: clean
	mkdir -p $(DESTINATION)
	$(SUDO) $(LUET) build $(BUILD_ARGS) --tree=$(TREE) --full --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild
rebuild:
	$(SUDO) $(LUET) build $(BUILD_ARGS) --tree=$(TREE) $(PACKAGES) --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild-all
rebuild-all:
	$(SUDO) $(LUET) build $(BUILD_ARGS) --tree=$(TREE) --full --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: create-repo
create-repo:
	$(SUDO) $(LUET) create-repo --tree "$(TREE)" \
    --output $(DESTINATION) \
    --packages $(DESTINATION) \
    --name "mocaccino-funtoo" \
    --descr "Mocaccino Funtoo $(ARCH)" \
    --urls "http://localhost:8000" \
    --tree-compression gzip \
    --tree-filename tree.tar \
    --meta-compression gzip \
    --type http

.PHONY: serve-repo
serve-repo:
	LUET_NOLOCK=true $(LUET) serve-repo --port 8000 --dir $(DESTINATION)

auto-bump:
	TREE_DIR=$(ROOT_DIR) $(LUET) autobump-github

autobump: auto-bump

repository:
	mkdir -p $(ROOT_DIR)/repository

repository/luet:
	git clone -b master --single-branch https://github.com/Luet-lab/luet-repo $(ROOT_DIR)/repository/luet

repository/extra:
	git clone -b master --single-branch https://github.com/mocaccinoos/mocaccino-extra $(ROOT_DIR)/repository/extra

repository/commons:
	git clone -b master --single-branch https://github.com/mocaccinoos/os-commons $(ROOT_DIR)/repository/commons

validate: repository repository/luet repository/extra repository/commons
	$(LUET) tree validate --tree $(ROOT_DIR)/repository --tree $(TREE) $(VALIDATE_OPTIONS)
