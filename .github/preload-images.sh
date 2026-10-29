#!/bin/bash
# Best-effort: pre-pull the mirror.gcr.io images referenced by charts/*/ci values on the runner and load them into
# the kind cluster. A failed pull only warns; the kubelet then pulls the image itself with its own retries.
set -uo pipefail

CLUSTER_NAME="${KIND_CLUSTER_NAME:-chart-testing}"
PRELOAD_REGISTRY="${PRELOAD_REGISTRY:-mirror.gcr.io}"
PULL_ATTEMPTS=5

list_images() {
  local registry_pattern="${PRELOAD_REGISTRY//./\\.}"
  for values_file in charts/*/ci/*.yaml; do
    yq -r "[.. | select(tag == \"!!map\" and has(\"repository\") and has(\"tag\")) | .repository + \":\" + (.tag | tostring)] + [.. | select(tag == \"!!str\" and test(\"^${registry_pattern}/\"))] | .[]" "$values_file"
  done | grep -E "^${PRELOAD_REGISTRY//./\\.}/[^:]+:[^/]+$" | sort -u
}

pull_with_retry() {
  local image="$1"
  for attempt in $(seq 1 "$PULL_ATTEMPTS"); do
    if docker pull --quiet "$image" > /dev/null; then
      return 0
    fi
    echo "Pull of ${image} failed (attempt ${attempt}/${PULL_ATTEMPTS})" >&2
    sleep $((attempt * 10))
  done
  return 1
}

while read -r image; do
  if pull_with_retry "$image" && kind load docker-image "$image" --name "$CLUSTER_NAME"; then
    echo "Preloaded ${image}"
  else
    echo "::warning::Could not preload ${image}; the cluster will pull it itself"
  fi
done < <(list_images)
