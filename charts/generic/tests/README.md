# Helm Unit Tests for Generic Chart

This directory contains unit tests for the generic Helm chart using the helm-unittest plugin.

## Running Tests

```bash
# Run all tests
helm unittest .

# Run specific test file
helm unittest -f tests/deployment_test.yaml .

# Run with verbose output
helm unittest --debug .

# Update snapshots
helm unittest -u .
```

## Test Structure

Each test file follows this structure:

```yaml
suite: test suite name        # Name of the test suite
templates:                    # List of templates to test
  - deployment.yaml           # Path relative to templates/
tests:                       # List of test cases
  - it: should do something  # Test description
    set:                     # Optional: Set values
      key: value
    values:                  # Optional: Use values file
      - values.yaml
    asserts:                 # List of assertions
      - isKind:
          of: Deployment
      - equal:
          path: metadata.name
          value: expected-name
```

## Common Assertions

### Document Assertions
- `hasDocuments`: Check document count
- `isKind`: Verify resource type
- `isAPIVersion`: Check API version
- `isNull`: Check if path is null
- `isNotNull`: Check if path is not null

### Value Assertions
- `equal`: Exact match
- `notEqual`: Not equal
- `contains`: Contains item in array
- `notContains`: Does not contain
- `lengthEqual`: Array/map length
- `exists`: Path exists
- `notExists`: Path does not exist

### Content Assertions
- `matchRegex`: Regex match
- `notMatchRegex`: Regex not match
- `matchSnapshot`: Compare with snapshot

## Example Test Cases

### Basic Deployment Test
```yaml
- it: should create deployment
  asserts:
    - isKind:
        of: Deployment
    - equal:
        path: metadata.name
        value: RELEASE-NAME-generic
```

### Conditional Resource Test
```yaml
- it: should not create when disabled
  set:
    service.enabled: false
  asserts:
    - hasDocuments:
        count: 0
```

### Array Content Test
```yaml
- it: should add environment variables
  set:
    env:
      - name: FOO
        value: bar
  asserts:
    - contains:
        path: spec.template.spec.containers[0].env
        content:
          name: FOO
          value: bar
```

### Complex Path Test
```yaml
- it: should set nested values
  set:
    ingress:
      enabled: true
      hosts:
        - host: example.com
          paths:
            - path: /
              pathType: Prefix
  asserts:
    - equal:
        path: spec.rules[0].host
        value: example.com
    - equal:
        path: spec.rules[0].http.paths[0].path
        value: /
```

## Tips

1. **Use RELEASE-NAME**: The release name in tests is always "RELEASE-NAME"
2. **Path syntax**: Use dot notation for nested paths, brackets for arrays
3. **Multiple documents**: Use `documentIndex` for multi-document templates
4. **Debug failing tests**: Use `--debug` flag to see rendered output
5. **Test organization**: Group related tests in the same suite

## Test Coverage

Current test files cover:
- `deployment_test.yaml` - Deployment resource tests
- `service_test.yaml` - Service resource tests
- (Add more as created...)

## Contributing

When adding new features:
1. Write tests for the new functionality
2. Ensure existing tests still pass
3. Update this README if adding new test patterns
