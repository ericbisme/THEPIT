BUTANE_IMAGE := quay.io/coreos/butane@sha256:13fec166cb47a8e053dcc23256c0ca41aaa1c61cab39793832aaf8894ca78c8f
BUILD_DIR := ../build/flatcar
NODE1_CANARY := $(BUILD_DIR)/k8s-node1-canary.ign
NODE1_DIAGNOSTIC := $(BUILD_DIR)/k8s-node1-diagnostic.ign
NODE1_IGNITION_SSH := $(BUILD_DIR)/k8s-node1-ignition-ssh.ign
NODE1_NFS_READONLY := $(BUILD_DIR)/k8s-node1-nfs-readonly.ign
NODE1_LOCAL_ROOT := $(BUILD_DIR)/k8s-node1-local-root.ign
NODE1_K3S := $(BUILD_DIR)/k8s-node1-k3s.ign

.PHONY: all node1-canary node1-diagnostic node1-ignition-ssh node1-nfs-readonly node1-local-root node1-k3s clean

all: node1-canary node1-diagnostic node1-ignition-ssh node1-nfs-readonly node1-local-root node1-k3s

node1-canary: $(NODE1_CANARY)

$(NODE1_CANARY): node1-canary.bu
	mkdir -p $(BUILD_DIR)
	podman run --rm --pull=never -i $(BUTANE_IMAGE) --pretty --strict < $< > $@
	jq -e '.ignition.version == "3.3.0"' $@ >/dev/null

node1-diagnostic: $(NODE1_DIAGNOSTIC)

$(NODE1_DIAGNOSTIC): node1-diagnostic.bu
	mkdir -p $(BUILD_DIR)
	podman run --rm --pull=never -i $(BUTANE_IMAGE) --pretty --strict < $< > $@
	jq -e '.ignition.version == "3.3.0"' $@ >/dev/null

node1-ignition-ssh: $(NODE1_IGNITION_SSH)

$(NODE1_IGNITION_SSH): node1-ignition-ssh.bu
	mkdir -p $(BUILD_DIR)
	podman run --rm --pull=never -i $(BUTANE_IMAGE) --pretty --strict < $< > $@
	jq -e '.ignition.version == "3.3.0"' $@ >/dev/null

node1-nfs-readonly: $(NODE1_NFS_READONLY)

$(NODE1_NFS_READONLY): node1-nfs-readonly.bu
	mkdir -p $(BUILD_DIR)
	podman run --rm --pull=never -i $(BUTANE_IMAGE) --pretty --strict < $< > $@
	jq -e '.ignition.version == "3.3.0"' $@ >/dev/null

node1-local-root: $(NODE1_LOCAL_ROOT)

$(NODE1_LOCAL_ROOT): node1-local-root.bu
	mkdir -p $(BUILD_DIR)
	podman run --rm --pull=never -i $(BUTANE_IMAGE) --pretty --strict < $< > $@
	jq -e '.ignition.version == "3.3.0"' $@ >/dev/null

node1-k3s: $(NODE1_K3S)

$(NODE1_K3S): node1-k3s.bu
	mkdir -p $(BUILD_DIR)
	podman run --rm --pull=never -i $(BUTANE_IMAGE) --pretty --strict < $< > $@
	jq -e '.ignition.version == "3.3.0"' $@ >/dev/null

clean:
	rm -rf $(BUILD_DIR)
