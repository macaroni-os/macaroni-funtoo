
BACKEND?=dockerv3
CONCURRENCY?=1
CI_ARGS?=
PACKAGES?=

# Abs path only. It gets copied in chroot in pre-seed stages
export ANISE_BUILD?=/usr/bin/anise-build
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DESTINATION?=$(ROOT_DIR)/build
COMPRESSION?=zstd
export TREE?=$(ROOT_DIR)/packages
REPO_CACHE?=macaronios/macaroni-eagle-amd64-cache
export REPO_CACHE
BUILD_ARGS?=--pull --no-spinner
GENIDX_ARGS?=--only-upper-level --compress=false
REPO_NAME?=macaroni-eagle
REPO_DESC?="Macaroni OS Eagle"
REPO_URL?="https://dl.macaronios.org/repos/macaroni-funtoo-systemd/"

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
build: clean genidx
	mkdir -p $(DESTINATION)
	$(SUDO) $(ANISE_BUILD) build $(BUILD_ARGS) --tree=$(TREE) $(PACKAGES) --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: build-all
build-all: clean genidx
	mkdir -p $(DESTINATION)
	$(SUDO) $(ANISE_BUILD) build $(BUILD_ARGS) --tree=$(TREE) --full --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild
rebuild: genidx
	$(SUDO) $(ANISE_BUILD) build $(BUILD_ARGS) --tree=$(TREE) $(PACKAGES) --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild-all
rebuild-all: genidx
	$(SUDO) $(ANISE_BUILD) build $(BUILD_ARGS) --tree=$(TREE) --full --destination $(DESTINATION) --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: genidx
genidx:
	$(SUDO) $(ANISE_BUILD) tree genidx $(GENIDX_ARGS) --tree=$(TREE)

.PHONY: create-repo
create-repo: genidx
	$(SUDO) $(ANISE_BUILD) create-repo --tree "$(TREE)" \
    --output $(DESTINATION) \
    --packages $(DESTINATION) \
    --name "$(REPO_NAME)" \
    --descr "$(REPO_DESC) $(ARCH)" \
    --urls "$(REPO_URL)" \
    --tree-compression $(COMPRESSION) \
    --tree-filename tree.tar.zst \
    --with-compilertree \
    --type http

.PHONY: serve-repo
serve-repo:
	ANISE_BUILD_NOLOCK=true $(ANISE_BUILD) serve-repo --port 8000 --dir $(DESTINATION)

repository:
	mkdir -p $(ROOT_DIR)/repository

repository/mark:
	git clone -b phoenix --single-branch https://github.com/macaroni-os/mark-repo $(ROOT_DIR)/repository/mark

repository/macaroni-commons:
	git clone -b master --single-branch https://github.com/macaroni-os/macaroni-commons $(ROOT_DIR)/repository/macaroni-commons

validate: repository repository/mark repository/macaroni-commons genidx
	$(SUDO) $(ANISE_BUILD) tree genidx $(GENIDX_ARGS) --tree $(ROOT_DIR)/repository
	$(ANISE_BUILD) tree validate --tree $(ROOT_DIR)/repository --tree $(TREE) $(VALIDATE_OPTIONS)
