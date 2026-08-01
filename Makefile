.PHONY: all build clean

# optional inputs for CPU and memory limits (defaults to 100% of available resources)
ROOT_DIR ?= $(shell pwd)
GRAPHENE_BRANCH ?= stable
KEYS_DIR ?= "$(ROOT_DIR)/keys"
OUTPUT_DIR ?= "$(ROOT_DIR)/output"
MAX_CPU_PERCENT ?= 100
MAX_MEM_PERCENT ?= 100


CPU_LIMIT := $(shell echo $$(( $(shell nproc --all) * $(MAX_CPU_PERCENT) / 100 )))
MEM_LIMIT := $(shell echo "$$(( $(shell free -m | awk '/^Mem:/{print $$2}') * $(MAX_MEM_PERCENT) / 100 ))m")

REPO_MIRROR     ?= "$(ROOT_DIR)/aosp_mirror"
ADEV_CACHE      ?= "$(ROOT_DIR)/adevtool_cache"


COMMON_PODMAN_FLAGS := \
	--rm \
	--pids-limit=-1 \
	-v "$(PWD)":/src:Z \
	-v "$(OUTPUT_DIR)":/output \
	-e USE_CCACHE=0 \
	-w /src


# Default target must be first
all:
	mkdir -p $(REPO_MIRROR)
	mkdir -p $(OUTPUT_DIR)
	$(call check_device)
	$(MAKE) clean
	$(MAKE) build-podman-image
	# $(MAKE) pull-repo
	$(MAKE) build-kernel

# Check required variables
check_device = $(if $(DEVICE),,$(error DEVICE is required))

# Build podman image
build-podman-image:
	podman build -t buildrom .

# Build kernel using podman
build-kernel:
	$(call check_device)
	podman run --rm --pids-limit=-1 -v "$(PWD)":/src:Z -v "$(OUTPUT_DIR)":/output -e USE_CCACHE=0 -w /src buildrom \
		/bin/bash -c 'export BUILD_METADATA_FILE=$$(python3 scripts/generate_env.py $(DEVICE) local local /output) && \
		python3 scripts/load_env.py $$BUILD_METADATA_FILE > .env && \
		echo "BUILD_METADATA_FILE=$$BUILD_METADATA_FILE" >> .env && \
		while IFS="=" read -r key value; do export "$$key=$$value"; done < .env && \
		/bin/bash /src/scripts/build_kernel.sh $(DEVICE)'

# Clean build directories
clean:
	rm -rfv build_metadata.json device_tmp/ kernel/ kernel_out/
