# Contributing

## Development Setup

```bash
git clone https://github.com/dnd-it/helm-charts.git
cd helm-charts
```

### Prerequisites

- [Helm 3.x](https://helm.sh/docs/intro/install/)
- [helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin
- [helm-docs](https://github.com/norwoodj/helm-docs) (for README generation)
- [kubeconform](https://github.com/yannh/kubeconform) (for manifest validation)
- [pre-commit](https://pre-commit.com/) (optional, for git hooks)

```bash
# Install Helm plugins
helm plugin install https://github.com/helm-unittest/helm-unittest.git

# Install pre-commit hooks
pre-commit install
```

## Workflow

### Adding a Feature

1. Create a branch from `main`
2. Make changes to chart templates in `charts/common/templates/`
3. Update default values if needed in `charts/common/values.yaml`
4. Add unit tests in `charts/generic/tests/`
5. Add CI test values in `charts/*/ci/` if needed
6. Run quality checks:

    ```bash
    make lint CHART=generic
    make test CHART=generic
    make template CHART=generic
    ```

7. Update documentation:

    ```bash
    make docs CHART=generic
    ```

8. Bump the chart version in `Chart.yaml`
9. Update `CHANGELOG.md`
10. Open a pull request

### Modifying a Wrapper Chart

Wrapper charts (web, api, worker, task) should only contain opinionated **value overrides**. Template logic belongs in the common library.

```
charts/web/
├── Chart.yaml           # Version and dependency on common
├── values.yaml          # Opinionated defaults only
├── templates/
│   └── common.yaml      # Single file: {{- include "common.loader.generate" . -}}
└── ci/
    └── default-values.yaml  # CI test values
```

### Adding a New Resource Type

1. Create the template in `charts/common/templates/classes/<category>/`
2. Add default values in `charts/common/values.yaml`
3. Include it in `charts/common/templates/loader/_generate.tpl`
4. Add unit tests
5. Add capability guards if the resource requires CRDs

## Code Style

- One resource per template file
- Name files after the resource type (`_deployment.tpl`, `_service.tpl`)
- Use `{{- ` to trim whitespace
- All configurable values go through `.Values`
- Use helpers from `_helpers.tpl` for repeated logic
- Add nil guards for optional nested values: `($config.container).resources`
- Conditional resources: `{{- if .Values.feature.enabled }}`

## Pre-commit Hooks

The repository uses pre-commit hooks that run automatically:

- **helm-docs** - Regenerates chart READMEs
- **schema-gen** - Regenerates `values.schema.json`
- Trailing whitespace and EOF fixes
- Merge conflict detection

## CI Pipeline

Every PR runs:

1. **Lint** - `ct lint` with chart-testing
2. **Unit tests** - `helm unittest` for all charts
3. **Docs validation** - Ensures helm-docs is up to date
4. **Kubeconform** - Validates manifests against K8s 1.32-1.35
5. **Install test** - Deploys to Kind clusters (K8s 1.32-1.35)

See [Testing](testing.md) for details.
