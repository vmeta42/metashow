#!/bin/bash

DIR="crdschemas"

rm -rf "$DIR"
mkdir "$DIR"

for crd in vendor/prometheus-operator/*-crd.libsonnet; do
	jq '.spec.versions[0].schema.openAPIV3Schema' < "$crd" > "$DIR/$(basename "$crd" | sed 's/-crd//;s/prometheuse/prometheus/;s/libsonnet/json/')"
done
