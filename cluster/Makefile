SHELL=/bin/bash -o pipefail

BIN_DIR?=$(shell pwd)/tmp/bin

JB_BIN=$(BIN_DIR)/jb
GOJSONTOYAML_BIN=$(BIN_DIR)/gojsontoyaml
JSONNET_BIN=$(BIN_DIR)/jsonnet
JSONNETLINT_BIN=$(BIN_DIR)/jsonnet-lint
JSONNETFMT_BIN=$(BIN_DIR)/jsonnetfmt
KUBECONFORM_BIN=$(BIN_DIR)/kubeconform
KUBESCAPE_BIN=$(BIN_DIR)/kubescape
TOOLING=$(JB_BIN) $(GOJSONTOYAML_BIN) $(JSONNET_BIN) $(JSONNETLINT_BIN) $(JSONNETFMT_BIN) $(KUBECONFORM_BIN=) $(KUBESCAPE_BIN=)

all: generate

.PHONY: clean
clean:
	# Remove all files and directories ignored by git.
	git clean -Xfd .

.PHONY: generate
generate: manifests

manifests: $(GOJSONTOYAML_BIN)
	./build.sh

crdschemas:
	./scripts/generate-schemas.sh

.PHONY: update
update: $(JB_BIN)
	$(JB_BIN) update

.PHONY: validate
validate: validate-1.23 validate-1.24

validate-1.23:
	KUBE_VERSION=1.23.6 $(MAKE) kubeconform

validate-1.24:
	KUBE_VERSION=1.24.1 $(MAKE) kubeconform

.PHONY: kubeconform
kubeconform: crdschemas manifests $(KUBECONFORM_BIN)
	$(KUBECONFORM_BIN) -kubernetes-version $(KUBE_VERSION) -schema-location 'default' -schema-location 'crdschemas/{{ .ResourceKind }}.json' -skip CustomResourceDefinition manifests/

.PHONY: kubescape
kubescape: $(KUBESCAPE_BIN) ## Runs a security analysis on generated manifests - failing if risk score is above threshold percentage 't'
	$(KUBESCAPE_BIN) scan -s framework -t $(KUBESCAPE_THRESHOLD) nsa manifests/*.yaml --exceptions 'kubescape-exceptions.json'

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(TOOLING): $(BIN_DIR)
	@echo Installing tools from scripts/tools.go
	@cd scripts && cat tools.go | grep _ | awk -F'"' '{print $$2}' | xargs -tI % go build -modfile=go.mod -o $(BIN_DIR) %

.PHONY: deploy
deploy:
