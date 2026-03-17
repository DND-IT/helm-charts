#!/bin/bash
mkdir -p ./.bin
export PATH="./.bin:$PATH"
set -euxo pipefail
# renovate: datasource=github-releases depName=kubeconform packageName=yannh/kubeconform
KUBECONFORM_VERSION=v0.7.0
# renovate: datasource=github-releases depName=semver2 packageName=Ariel-Rodriguez/sh-semversion-2
SEMVER_VERSION=v1.0.5
CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/main -- charts | cut -d '/' -f 2 | uniq)"
SCHEMA_LOCATION="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"
CRD_SCHEMA_LOCATION="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"

# install kubeconform
curl --silent --show-error --fail --location --output /tmp/kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/"${KUBECONFORM_VERSION}"/kubeconform-linux-amd64.tar.gz
tar -C .bin/ -xf /tmp/kubeconform.tar.gz kubeconform
chmod +x .bin/kubeconform

# install semver compare
curl -sSfLo .bin/semver2 https://raw.githubusercontent.com/Ariel-Rodriguez/sh-semversion-2/${SEMVER_VERSION}/semver2.sh
chmod +x .bin/semver2

# Initialize apis array
apis=(
  --api-versions batch/v1/CronJob
  # Gateway API
  --api-versions gateway.networking.k8s.io/v1/HTTPRoute
  --api-versions gateway.networking.k8s.io/v1/GRPCRoute
  --api-versions gateway.networking.k8s.io/v1beta1/ReferenceGrant
  --api-versions gateway.networking.k8s.io/v1alpha2/TCPRoute
  --api-versions gateway.networking.k8s.io/v1alpha2/TLSRoute
  --api-versions gateway.networking.k8s.io/v1alpha2/UDPRoute
  # AWS Load Balancer Controller v3
  --api-versions gateway.k8s.aws/v1beta1/TargetGroupConfiguration
  --api-versions gateway.k8s.aws/v1beta1/LoadBalancerConfiguration
  --api-versions gateway.k8s.aws/v1beta1/ListenerRuleConfiguration
)


# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  # Skip if chart directory doesn't exist
  if [ ! -d "charts/${CHART_DIR}" ]; then
    echo "Skipping ${CHART_DIR} (directory not found)"
    continue
  fi

  # Skip library charts (they can't be templated)
  chart_type=$(grep '^type:' "charts/${CHART_DIR}/Chart.yaml" 2>/dev/null | awk '{print $2}' || echo "application")
  if [ "$chart_type" = "library" ]; then
    echo "Skipping library chart ${CHART_DIR}"
    continue
  fi

  (cd "charts/${CHART_DIR}"; helm dependency build)

  # Check if ci directory exists with yaml files
  if [ ! -d "charts/${CHART_DIR}/ci" ] || ! ls charts/"${CHART_DIR}"/ci/*.yaml 1> /dev/null 2>&1; then
    echo "No CI values files for ${CHART_DIR}, using default values"
    helm template \
      "${apis[@]}" \
      charts/"${CHART_DIR}" | kubeconform \
        -strict \
        -ignore-missing-schemas \
        -kubernetes-version "${KUBERNETES_VERSION#v}" \
        -schema-location "${SCHEMA_LOCATION}" \
        -schema-location "${CRD_SCHEMA_LOCATION}"
    continue
  fi

  for VALUES_FILE in charts/"${CHART_DIR}"/ci/*.yaml; do
    helm template \
      "${apis[@]}" \
      --values "${VALUES_FILE}" \
      charts/"${CHART_DIR}" | kubeconform \
        -strict \
        -ignore-missing-schemas \
        -kubernetes-version "${KUBERNETES_VERSION#v}" \
        -schema-location "${SCHEMA_LOCATION}" \
        -schema-location "${CRD_SCHEMA_LOCATION}"
  done
done
