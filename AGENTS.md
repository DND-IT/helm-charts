# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Helm charts repository for Kubernetes deployments, primarily targeting Amazon EKS. The repository contains production-ready charts in `/charts` and experimental charts in `/incubating`.

## Essential Commands

### Development Workflow
```bash
# Lint a specific chart
make lint CHART=generic

# Run unit tests for a chart
make test CHART=generic

# Generate and preview templates
make template CHART=generic

# Install chart to current kubectl context
make install CHART=generic

# Package chart for distribution
make package CHART=generic

# Generate documentation
make docs CHART=generic

# Generate JSON schema for a chart
make schema CHART=generic
```

### Batch Operations
```bash
# Lint all charts
make lint-all

# Test all charts
make test-all

# Run all quality checks
make quality-all

# Generate schemas for all charts
make schema-all
```

### Testing Commands
```bash
# Run unit tests with helm-unittest plugin
helm unittest charts/generic

# Validate manifests with kubeconform
make kubeconform CHART=generic

# Run integration tests in Kind cluster
make integration-test CHART=generic
```

## Architecture and Patterns

### Chart Organization
- **Production charts** (`/charts`): generic, custom-resources, karpenter-resources
- **Deprecated charts** (`/charts`): webapp, cronjob (use generic chart instead)
- **Incubating charts** (`/incubating`): common library chart
- Each chart follows standard Helm structure with templates/, values.yaml, Chart.yaml

### Key Design Patterns

1. **Generic Chart** (`charts/generic`):
   - Highly flexible chart supporting all Kubernetes workload types
   - Supports Deployment, StatefulSet, DaemonSet, Job, and CronJob
   - Full-featured with Service, Ingress, Gateway API, HPA, VPA, PDB
   - Comprehensive security, monitoring, and persistence options
   - Modular template architecture with extensive configuration

2. **Template Helpers**:
   - Common labels, selectors, and names generated via _helpers.tpl
   - Consistent naming: `{{ include "generic.fullname" . }}`
   - Standard labels: `{{ include "generic.labels" . }}`

3. **Values Structure**:
   - Environment-specific values in `ci/` directories
   - Default values with extensive inline documentation
   - Schema validation through CI testing

### Testing Strategy
- **Unit tests**: Located in `charts/*/tests/` using helm-unittest
- **CI values**: Test configurations in `charts/*/ci/` for different scenarios
- **Integration tests**: Deploy to Kind clusters via GitHub Actions
- **Manifest validation**: Kubeconform against multiple K8s versions (1.29-1.32)

### CI/CD Pipeline
- GitHub Actions workflow in `.github/workflows/`
- Triggered on main branch pushes and PRs
- Tests against multiple Kubernetes versions
- Automated documentation generation with helm-docs
- Chart publishing to GitHub Pages

## Development Guidelines

### When Adding New Features
1. Update the chart version in Chart.yaml
2. Add new templates in the templates/ directory
3. Document new values in values.yaml with descriptions
4. Create unit tests in tests/ directory
5. Add CI test values if needed
6. Run `make docs CHART=<name>` to update README
7. Run `make schema CHART=<name>` to generate/update JSON schema

### When Modifying Charts
1. Always run `make lint CHART=<name>` before committing
2. Ensure unit tests pass with `make test CHART=<name>`
3. Test template generation with `make template CHART=<name>`
4. Update documentation if values change
5. Schema generation happens automatically via pre-commit hook

### Common Patterns to Follow
- Use `.Values` for all configurable options
- Leverage `_helpers.tpl` for repeated template logic
- Include proper RBAC resources when needed
- Support both ClusterIP and LoadBalancer service types
- Implement health checks (liveness/readiness probes)
- Use `{{ .Release.Namespace }}` for namespace-aware resources

## Important Conventions

### Naming Conventions
- Chart names: lowercase, hyphen-separated
- Resource names: `{{ include "chartname.fullname" . }}`
- Labels: Follow Kubernetes recommended labels

### Values Best Practices
- Group related configuration together
- Provide sensible defaults
- Document each value with comments
- Use nested structures for complex configs

### Template Organization
- One resource per file when possible
- Name files after the resource type (deployment.yaml, service.yaml)
- Use YAML anchors and aliases to reduce duplication
- Conditional resources with `{{- if .Values.feature.enabled }}`

## Troubleshooting Common Issues

### Template Errors
- Check indentation in templates (use `{{- ` to trim whitespace)
- Verify all `.Values` paths exist
- Use `make template` to preview generated manifests

### Test Failures
- Ensure helm-unittest plugin is installed
- Check that test assertions match template output
- Review CI test values for missing configurations

### Lint Warnings
- Follow lintconf.yaml rules for YAML formatting
- Ensure Chart.yaml has all required fields
- Check for deprecated Kubernetes APIs

## Schema Generation

### Automatic Schema Generation
The repository uses a pre-commit hook to automatically generate JSON schemas when you modify Helm chart values:
- Schemas are generated using the `helm schema-gen` plugin
- Dynamic fields (extraDeployments, extraServices, etc.) are automatically enhanced
- Pre-commit hook runs on changes to `values.yaml`, CI values files, or `Chart.yaml`

### Manual Schema Generation
```bash
# Generate schema for a specific chart
make schema CHART=generic

# Generate schemas for all charts
make schema-all
```

### Schema Enhancement
The schema generation script automatically enhances schemas for common dynamic patterns:
- `extraDeployments`, `extraServices`, `extraIngresses`: Additional K8s resources
- `extraConfigMaps`, `extraSecrets`: Additional configuration objects
- `jobs`, `cronjobs`: Job configurations
- `hooks`: Helm hook configurations
- `extraVolumes`, `extraVolumeMounts`: Additional storage configurations

## Development Reminders
- As you make changes be sure to update the changelog
- JSON schemas are generated automatically via pre-commit hooks
