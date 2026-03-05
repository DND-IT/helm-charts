# DND-IT Helm Charts

Welcome to the DND-IT Helm Charts repository! This repository contains a collection of Helm charts for deploying applications on Kubernetes.

[![GitHub Repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/dnd-it/helm-charts)
[![Helm Charts](https://img.shields.io/badge/Helm-Charts-0F1689?logo=helm)](https://dnd-it.github.io/helm-charts)

## Available Charts

### Opinionated Charts (Thin Wrappers)

These charts are thin wrappers around the [common](./charts/common) library chart. They provide **opinionated defaults** for specific workload types so teams can deploy with minimal configuration — just set your image and go.

Each chart includes sensible defaults for security contexts, health probes, scheduling, and Datadog integration, while still allowing full customization via values overrides.

| Chart | Description | Documentation |
|-------|-------------|---------------|
| [web](./charts/web) | External-facing web applications. Ingress enabled by default with ALB. | [README](./charts/web/README.md) |
| [api](./charts/api) | Internal API services. Service enabled, ingress disabled by default. | [README](./charts/api/README.md) |
| [worker](./charts/worker) | Background worker processes. No service or ingress. | [README](./charts/worker/README.md) |
| [task](./charts/task) | Scheduled CronJob workloads. No service, ingress, or HPA. | [README](./charts/task/README.md) |

**Why thin wrappers?** The `generic` chart is powerful but requires teams to configure everything from scratch. The thin wrappers solve this by:

- **Reducing boilerplate** — no need to repeatedly set the same defaults across services
- **Enforcing conventions** — consistent security contexts, probe paths (`/livez`, `/readyz`), and scheduling across all deployments
- **Simplifying onboarding** — new services only need `image.repository` and `image.tag` to get a production-ready deployment
- **Staying flexible** — since they use the common library, any value can still be overridden

### Other Charts

| Chart | Description | Documentation |
|-------|-------------|---------------|
| [generic](./charts/generic) | A highly flexible and unopinionated Helm chart for deploying any Kubernetes workload. | [README](./charts/generic/README.md) |
| [common](./charts/common) | Shared library chart with common templates and helpers. Used as a dependency by the thin wrapper charts. | [README](./charts/common/README.md) |
| [custom-resources](./charts/custom-resources) | Deploy arbitrary Kubernetes resources | [README](./charts/custom-resources/README.md) |
| [karpenter-resources](./charts/karpenter-resources) | Karpenter provisioner and node pool configurations | [README](./charts/karpenter-resources/README.md) |

### Deprecated Charts

| Chart | Description | Documentation |
|-------|-------------|---------------|
| [webapp](./charts/webapp) | [DEPRECATED] Use `web` instead | [README](./charts/webapp/README.md) |
| [cronjob](./charts/cronjob) | [DEPRECATED] Use `task` instead | [README](./charts/cronjob/README.md) |

## Kubernetes Version Support

Our charts support Kubernetes versions that are currently maintained by major cloud providers:

- [Amazon Elastic Kubernetes Service (Amazon EKS)](https://endoflife.date/amazon-eks) - 1.29+
- Other cloud providers with Kubernetes 1.29+

## Quick Start

### Add Helm Repository

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update
```

### Search Available Charts

```bash
helm search repo dnd-it
```

### Install a Chart

Install using default values:
```bash
helm install my-release dnd-it/<chart-name>
```

Install with custom values file:
```bash
helm install my-release dnd-it/<chart-name> -f values.yaml
```

Install specific version:
```bash
helm install my-release dnd-it/<chart-name> --version <version>
```

### Example: Deploy with Generic Chart

```bash
# Deploy a web application
helm install my-app dnd-it/generic \
  --set image.repository=nginx \
  --set image.tag=latest \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=myapp.example.com

# Deploy a CronJob
helm install my-job dnd-it/generic \
  --set workload.type=cronjob \
  --set cronjob.schedule="0 2 * * *" \
  --set image.repository=myorg/backup-job
```

## Values Schema Generation

Each chart includes a `values.schema.json` file that provides JSON Schema validation for `values.yaml`. These schemas are generated using the [helm-schema](https://github.com/losisin/helm-values-schema-json) Helm plugin.

### Installing the Plugin

```bash
helm plugin install https://github.com/losisin/helm-values-schema-json
```

### Generating Schemas

Use the Makefile targets to generate schemas:

```bash
# Generate schema for a specific chart
make schema CHART=generic

# Generate schemas for all charts
make schema-all
```

Or run `helm schema` directly from the chart directory:

```bash
cd charts/generic
helm schema
```

This reads `values.yaml` and produces `values.schema.json` using the [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12/schema) specification.

You can also generate from multiple values files (e.g. to capture CI test values):

```bash
helm schema -f values.yaml -f ci/test-values.yaml
```

### Schema Annotations

You can control schema generation by adding `@schema` annotations as comments in `values.yaml`. Each annotation must have `@schema` followed by the property on the **same line**:

```yaml
# @schema type: string
# @schema required: true
image:
  repository: nginx

# @schema minimum: 1
replicaCount: 1

# @schema type: [string, integer]
minAvailable: 50%
```

**Important:** Multi-line annotations require `@schema` on each line:

```yaml
# Correct
# @schema type: [string, integer]
# @schema minimum: 0
minAvailable: 50%

# Wrong - will not work
# @schema
# type: [string, integer]
minAvailable: 50%
```

See the [helm-schema documentation](https://github.com/losisin/helm-values-schema-json#annotations) for the full list of supported annotations.

## Contributing

We welcome contributions! When working with this repository locally:

### Prerequisites

- Helm 3.x
- Kubernetes 1.29+
- kubectl

### Building Dependencies

Some charts may have dependencies that need to be built:

```bash
cd charts/<chart-name>
helm dependency build
```

### Testing Charts

Test template rendering:
```bash
helm template test-release ./charts/<chart-name> -f values.yaml
```

Run built-in tests:
```bash
helm test test-release
```

### Linting

```bash
helm lint ./charts/<chart-name>
```

## Repository Structure

```
helm-charts/
├── charts/
│   ├── common/              # Shared library chart (templates & helpers)
│   ├── web/                 # Opinionated: external web applications
│   ├── api/                 # Opinionated: internal API services
│   ├── worker/              # Opinionated: background worker processes
│   ├── task/                # Opinionated: scheduled CronJob workloads
│   ├── generic/             # Flexible multi-purpose chart
│   ├── custom-resources/    # Custom resources chart
│   ├── karpenter-resources/ # Karpenter configurations
│   ├── webapp/              # [DEPRECATED] Use web instead
│   └── cronjob/             # [DEPRECATED] Use task instead
└── README.md                # This file
```

## Support

- 📖 [View on GitHub](https://github.com/dnd-it/helm-charts)
- 🐛 [Report Issues](https://github.com/dnd-it/helm-charts/issues)
- 💡 [Request Features](https://github.com/dnd-it/helm-charts/issues/new)

## License

This repository is maintained by DND-IT.
