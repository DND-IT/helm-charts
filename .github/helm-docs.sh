#!/bin/bash

mkdir ./.bin
export PATH="./.bin:$PATH"

set -euxo pipefail

# renovate: datasource=github-releases depName=helm-docs packageName=norwoodj/helm-docs
HELM_DOCS_VERSION=1.13.1
os=$(uname -s)
arch=$(uname -m)
# install helm-docs
curl --silent --show-error --fail --location --output /tmp/helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v"${HELM_DOCS_VERSION}"/helm-docs_"${HELM_DOCS_VERSION}"_"$os"_"$arch".tar.gz
tar -C .bin/ -xf /tmp/helm-docs.tar.gz helm-docs

# validate docs
helm-docs
git diff --exit-code
