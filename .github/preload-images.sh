#!/bin/bash
# Pre-pull the public.ecr.aws images used by charts/*/ci values on the runner and load them into the kind cluster,
# so the kind nodes never hit the anonymous public ECR rate limit.
set -euo pipefail

CLUSTER_NAME="${KIND_CLUSTER_NAME:-chart-testing}"

IMAGES=(
  public.ecr.aws/docker/library/busybox:1.36
  public.ecr.aws/nginx/nginx-unprivileged:1.25-alpine
)

pull_with_retry() {
  local image="$1"
  for attempt in 1 2 3 4 5; do
    if docker pull --quiet "$image"; then
      return 0
    fi
    echo "Pull of ${image} failed (attempt ${attempt}/5), retrying" >&2
    sleep $((attempt * 15))
  done
  return 1
}

for image in "${IMAGES[@]}"; do
  pull_with_retry "$image"
  kind load docker-image "$image" --name "$CLUSTER_NAME"
done
