#!/usr/bin/env bash

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to use project tooling
PATH="$(pwd)/tmp/bin:${PATH}"
rm -rf manifests
mkdir -p manifests/setup

# Calling gojsontoyaml is optional, but we would like to generate yaml, not json
#jsonnet -J cluster/vendor cluster/example.jsonnet | gojsontoyaml > example.yaml
jsonnet -J vendor -m manifests example.jsonnet | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}

find manifests -type f ! -name '*.yaml' -delete
