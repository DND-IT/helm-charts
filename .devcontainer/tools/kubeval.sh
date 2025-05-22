#!/usr/bin/env bash

set -euo pipefail

check_semver "$KUBECONFORM_VERSION"

# install kubeconform
curl --silent --show-error --fail --location --output /tmp/kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/"${KUBECONFORM_VERSION}"/kubeconform-linux-amd64.tar.gz
tar -C .bin/ -xf /tmp/kubeconform.tar.gz kubeconform
chmod +x .bin/kubeconform

kubeconform --version
