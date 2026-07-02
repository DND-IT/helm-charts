#!/usr/bin/env bash
# Generate values.schema.json for Helm charts via the helm-values-schema-json plugin.
#
# Usage:
#   scripts/gen-helm-schema.sh                  # regenerate schemas for ALL charts
#   scripts/gen-helm-schema.sh <file> [file...] # regenerate only the charts owning the given files
#
# Used by the pre-commit "helm-schema" hook (selective, gets changed files) and by
# CI (no args, regenerates everything then checks for drift). Discovers charts by
# walking up to the nearest Chart.yaml, so it works regardless of nesting depth.
set -euo pipefail

# Deprecated charts to skip (keep in sync with Makefile SCHEMA_SKIP_CHARTS).
SKIP_CHARTS=("webapp" "cronjob")

# Directory containing the charts.
CHART_ROOT="charts"

is_skipped() {
  local name="$1"
  for s in "${SKIP_CHARTS[@]}"; do
    [ "$s" = "$name" ] && return 0
  done
  return 1
}

# Echo the chart root (nearest ancestor directory containing Chart.yaml) for a path.
chart_root_for() {
  local d="$1"
  [ -f "$d" ] && d="$(dirname "$d")"
  while [ -n "$d" ] && [ "$d" != "." ] && [ "$d" != "/" ]; do
    if [ -f "$d/Chart.yaml" ]; then
      printf '%s\n' "$d"
      return 0
    fi
    d="$(dirname "$d")"
  done
  return 1
}

if ! helm plugin list 2>/dev/null | grep -q '^schema'; then
  echo "helm 'schema' plugin not installed." >&2
  echo "Install it with: helm plugin install --verify=false https://github.com/losisin/helm-values-schema-json" >&2
  exit 1
fi

declare -A charts=()
if [ "$#" -eq 0 ]; then
  while IFS= read -r chart_yaml; do
    charts["$(dirname "$chart_yaml")"]=1
  done < <(find "$CHART_ROOT" -name Chart.yaml -not -path '*/charts/*')
else
  for f in "$@"; do
    if root="$(chart_root_for "$f")"; then
      charts["$root"]=1
    fi
  done
fi

status=0
for dir in "${!charts[@]}"; do
  name="$(basename "$dir")"
  if is_skipped "$name"; then
    echo "Skipping schema for deprecated chart: $name"
    continue
  fi
  echo "Generating schema: $dir/values.schema.json"
  if ! ( cd "$dir" && helm schema ); then
    echo "FAILED to generate schema for: $name" >&2
    status=1
  fi
done

exit "$status"
