# Testing Guide for Generic Helm Chart

This guide explains how to use the helm-unittest plugin to test Helm charts.

## Installation

```bash
# Install the plugin
helm plugin install https://github.com/helm-unittest/helm-unittest.git

# Verify installation
helm unittest --help
```

## Running Tests

```bash
# Run all tests in the tests/ directory
helm unittest .

# Run specific test file
helm unittest -f tests/deployment_test.yaml .

# Run multiple specific files
helm unittest -f tests/deployment_test.yaml -f tests/service_test.yaml .

# Run with color output
helm unittest --color .

# Run with debug output (shows rendered templates)
helm unittest --debug .

# Update snapshots
helm unittest -u .

# Output results in JUnit format
helm unittest -o test-results.xml .
```

## Writing Tests

### Basic Structure

```yaml
suite: test suite name           # Descriptive name for the test suite
templates:                       # List of templates to test
  - core/deployment.yaml        # Path relative to templates/
tests:                          # Array of test cases
  - it: should do something     # Test description
    set:                        # Optional: Override values
      key.nested: value
    values:                     # Optional: Load values from file
      - custom-values.yaml
    release:                    # Optional: Override release values
      name: my-release
      namespace: my-namespace
    asserts:                    # Array of assertions
      - equal:
          path: metadata.name
          value: expected-value
```

### Common Assertions

#### Document Assertions
```yaml
# Check if documents exist
- hasDocuments:
    count: 1  # Exact count

# Check document kind
- isKind:
    of: Deployment

# Check API version
- isAPIVersion:
    of: apps/v1

# Check multiple documents
- hasDocuments:
    count: 2
- equal:
    path: metadata.name
    value: my-service
    documentIndex: 1  # 0-based index
```

#### Path Assertions
```yaml
# Check if path exists
- exists:
    path: spec.replicas

# Check if path doesn't exist
- notExists:
    path: spec.replicas

# Check equality
- equal:
    path: metadata.name
    value: my-app

# Check inequality
- notEqual:
    path: spec.type
    value: LoadBalancer

# Check null
- isNull:
    path: spec.clusterIP

# Check not null
- isNotNull:
    path: spec.selector
```

#### Array and Map Assertions
```yaml
# Check array length
- lengthEqual:
    path: spec.ports
    count: 2

# Check if array contains item
- contains:
    path: spec.template.spec.containers
    content:
      name: nginx
      image: nginx:latest

# Check if array doesn't contain item
- notContains:
    path: spec.template.spec.containers
    content:
      name: sidecar

# Check if all items match
- containsAll:
    path: metadata.labels
    content:
      app: my-app
      version: v1
```

#### String Assertions
```yaml
# Regex matching
- matchRegex:
    path: metadata.name
    pattern: "^[a-z][a-z0-9-]*$"

# Not matching regex
- notMatchRegex:
    path: metadata.name
    pattern: "[A-Z]"

# Match snapshot (stored in __snapshot__/)
- matchSnapshot:
    path: spec
```

#### Advanced Assertions
```yaml
# Custom validation with JQ
- validate:
    path: spec.template.spec.containers[0]
    expression: |
      .resources.limits.memory == "512Mi" and
      .resources.requests.memory == "256Mi"

# Check rendered output
- failedTemplate:
    errorMessage: "value is required"
```

## Test Examples

### Testing Conditional Resources

```yaml
suite: test conditional rendering
templates:
  - core/service.yaml
tests:
  - it: should create service when enabled
    set:
      service.enabled: true
    asserts:
      - hasDocuments:
          count: 1
      - isKind:
          of: Service

  - it: should not create service when disabled
    set:
      service.enabled: false
    asserts:
      - hasDocuments:
          count: 0
```

### Testing Multiple Workload Types

```yaml
suite: test workload types
templates:
  - core/deployment.yaml
  - core/statefulset.yaml
  - core/daemonset.yaml
tests:
  - it: should create deployment
    set:
      workload.type: deployment
    asserts:
      - template: core/deployment.yaml
        hasDocuments:
          count: 1
      - template: core/statefulset.yaml
        hasDocuments:
          count: 0

  - it: should create statefulset
    set:
      workload.type: statefulset
    asserts:
      - template: core/deployment.yaml
        hasDocuments:
          count: 0
      - template: core/statefulset.yaml
        hasDocuments:
          count: 1
```

### Testing Complex Values

```yaml
suite: test complex configuration
templates:
  - networking/ingress.yaml
tests:
  - it: should configure ALB ingress
    set:
      ingress:
        enabled: true
        controller: alb
        hosts:
          - host: app.example.com
            paths:
              - path: /
                pathType: Prefix
        alb:
          annotations:
            alb.ingress.kubernetes.io/scheme: internet-facing
            alb.ingress.kubernetes.io/target-type: ip
    asserts:
      - equal:
          path: metadata.annotations["alb.ingress.kubernetes.io/scheme"]
          value: internet-facing
      - equal:
          path: spec.rules[0].host
          value: app.example.com
      - equal:
          path: spec.rules[0].http.paths[0].path
          value: /
```

### Testing with Values Files

```yaml
suite: test with values files
templates:
  - core/deployment.yaml
tests:
  - it: should use production values
    values:
      - ../ci/deployment-web-app-values.yaml
    asserts:
      - equal:
          path: spec.replicas
          value: 3
      - exists:
          path: spec.template.spec.containers[0].resources
```

### Testing Error Cases

```yaml
suite: test validation
templates:
  - core/deployment.yaml
tests:
  - it: should fail without required values
    set:
      image.repository: ""
    asserts:
      - failedTemplate:
          errorMessage: "image.repository is required"
```

## Best Practices

1. **Organize Tests by Feature**: Group related tests in the same file
2. **Use Descriptive Names**: Make test names clear about what they're testing
3. **Test Edge Cases**: Include tests for empty values, invalid inputs
4. **Test Combinations**: Test how different features interact
5. **Keep Tests Fast**: Avoid loading unnecessary templates
6. **Use documentIndex**: When testing multiple documents, be explicit
7. **Test Default Values**: Ensure defaults work as expected
8. **Test Overrides**: Verify that custom values override defaults properly

## Debugging Failed Tests

```bash
# Run with debug to see rendered output
helm unittest --debug -f tests/failing_test.yaml .

# Run with verbose output
helm unittest -v -f tests/failing_test.yaml .

# Test template rendering directly
helm template my-release . -f values.yaml --debug
```

## Common Issues

### Template Not Found
```yaml
# Wrong
templates:
  - deployment.yaml  # Missing subfolder

# Correct
templates:
  - core/deployment.yaml
```

### Path Not Found
```yaml
# Use --debug to see actual structure
helm unittest --debug -f tests/mytest.yaml .

# Common issues:
# - Array index out of bounds
# - Missing nested keys
# - Wrong documentIndex
```

### Multiple Documents
```yaml
# When template produces multiple documents
tests:
  - it: should test second document
    asserts:
      - equal:
          path: metadata.name
          value: my-service
          documentIndex: 1  # 0-based
```

## CI Integration

```yaml
# .github/workflows/test.yml
name: Test Charts
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/setup-helm@v3
      - name: Install unittest plugin
        run: helm plugin install https://github.com/helm-unittest/helm-unittest
      - name: Run tests
        run: |
          cd charts/generic
          helm unittest .
```
