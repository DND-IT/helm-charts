# Installation

## Add the Helm Repository

Charts are published as OCI artifacts to GitHub Container Registry:

```bash
# Pull a chart directly via OCI
helm pull oci://ghcr.io/dnd-it/helm-charts/web --version 1.2.0
```

## Install a Chart

```bash
helm install my-app oci://ghcr.io/dnd-it/helm-charts/web \
  --version 1.2.0 \
  --set image.repository=my-registry/my-app \
  --set image.tag=1.0.0
```

Or with a values file:

```bash
helm install my-app oci://ghcr.io/dnd-it/helm-charts/web \
  --version 1.2.0 \
  -f values.yaml
```

## Available Charts

| Chart | OCI Reference |
|-------|---------------|
| generic | `oci://ghcr.io/dnd-it/helm-charts/generic` |
| web | `oci://ghcr.io/dnd-it/helm-charts/web` |
| worker | `oci://ghcr.io/dnd-it/helm-charts/worker` |
| task | `oci://ghcr.io/dnd-it/helm-charts/task` |
| karpenter-resources | `oci://ghcr.io/dnd-it/helm-charts/karpenter-resources` |
| datadog-resources | `oci://ghcr.io/dnd-it/helm-charts/datadog-resources` |
| custom-resources | `oci://ghcr.io/dnd-it/helm-charts/custom-resources` |

## Local Development

Clone the repository for local development:

```bash
git clone https://github.com/dnd-it/helm-charts.git
cd helm-charts

# Build dependencies for a chart
helm dependency build charts/web

# Template locally
helm template my-app charts/web -f my-values.yaml
```
