# Testing

## Test Types

### Unit Tests (helm-unittest)

Unit tests validate template rendering without a cluster. Located in `charts/*/tests/`.

```bash
# Run all tests for a chart
helm unittest charts/generic

# Run a specific test file
helm unittest charts/generic -f tests/deployment_test.yaml
```

### CI Values

Test configurations in `charts/*/ci/` are used by both kubeconform and chart-testing (ct):

```
charts/generic/ci/
├── minimal-values.yaml      # Bare minimum configuration
├── complete-values.yaml     # All features enabled
├── web-app-values.yaml      # Web application pattern
├── advanced-values.yaml     # Advanced features
├── jobs-values.yaml         # Jobs and CronJobs
└── registry-values.yaml     # Global registry configuration
```

### Manifest Validation (kubeconform)

Validates rendered manifests against Kubernetes JSON schemas:

```bash
make kubeconform CHART=generic
```

Runs against multiple Kubernetes versions (1.32-1.35).

### Integration Tests

Deploy charts to a Kind cluster:

```bash
make integration-test CHART=generic
```

## Writing Unit Tests

Tests use the [helm-unittest](https://github.com/helm-unittest/helm-unittest) framework.

### Basic Test Structure

```yaml
suite: test deployment
templates:
  - common.yaml    # All resources come from this single template
tests:
  - it: should create a deployment
    set:
      image.repository: my-app
      image.tag: "1.0.0"
    asserts:
      - isKind:
          of: Deployment
        documentSelector:
          path: kind
          value: Deployment
```

### Document Selectors

Since all resources render from `common.yaml`, use `documentSelector` to target specific resources:

```yaml
asserts:
  - equal:
      path: spec.replicas
      value: 3
    documentSelector:
      path: kind
      value: Deployment

  - equal:
      path: spec.type
      value: ClusterIP
    documentSelector:
      path: kind
      value: Service
```

### Testing Values

```yaml
  - it: should set pod-level resources
    set:
      resources:
        requests:
          cpu: "500m"
          memory: "256Mi"
    asserts:
      - equal:
          path: spec.template.spec.resources.requests.cpu
          value: "500m"
        documentSelector:
          path: kind
          value: Deployment
```

### Testing with API Versions

For resources that require CRDs (Gateway API, VPA), pass `--api-versions`:

```yaml
# In the test file, capabilities are automatically available
# For manual testing:
helm template charts/generic \
  --api-versions gateway.networking.k8s.io/v1/HTTPRoute \
  --api-versions gateway.k8s.aws/v1beta1/TargetGroupConfiguration
```

## CRDs in CI

The CI pipeline installs CRDs before running tests:

- **Gateway API** (standard + experimental channels)
- **AWS Load Balancer Controller v3** (TargetGroupConfiguration, LoadBalancerConfiguration, ListenerRuleConfiguration)
- **Karpenter** (NodePool, EC2NodeClass)

See `.github/install-crds.sh` for the full list.
