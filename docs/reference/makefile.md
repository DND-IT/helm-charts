# Makefile Commands

The repository includes a Makefile for common development tasks.

## Per-Chart Commands

All commands accept a `CHART=<name>` parameter:

```bash
make lint CHART=generic
make test CHART=generic
make template CHART=generic
make install CHART=generic
make package CHART=generic
make docs CHART=generic
make schema CHART=generic
```

| Command | Description |
|---------|-------------|
| `make lint CHART=<name>` | Lint a chart with helm lint |
| `make test CHART=<name>` | Run unit tests with helm-unittest |
| `make template CHART=<name>` | Generate and preview rendered templates |
| `make install CHART=<name>` | Install chart to current kubectl context |
| `make package CHART=<name>` | Package chart as .tgz |
| `make docs CHART=<name>` | Generate README with helm-docs |
| `make schema CHART=<name>` | Generate values.schema.json |
| `make kubeconform CHART=<name>` | Validate manifests with kubeconform |

## Batch Commands

Run operations across all charts:

| Command | Description |
|---------|-------------|
| `make lint-all` | Lint all charts |
| `make test-all` | Run all unit tests |
| `make quality-all` | Run all quality checks |
| `make schema-all` | Generate schemas for all charts |

## Testing

```bash
# Unit tests with helm-unittest
helm unittest charts/generic

# Validate manifests against K8s API schemas
make kubeconform CHART=generic

# Integration test in Kind cluster
make integration-test CHART=generic
```

## Dependencies

```bash
# Build chart dependencies (pulls common library)
helm dependency build charts/web

# Update chart dependencies
helm dependency update charts/web
```
