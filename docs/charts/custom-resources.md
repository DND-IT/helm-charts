# Custom Resources Chart

A generic chart for deploying arbitrary Kubernetes custom resources. Use this when you need to manage CRDs that don't have a dedicated chart.

## Basic Usage

```yaml
resources:
  - apiVersion: example.com/v1
    kind: MyCustomResource
    metadata:
      name: my-resource
    spec:
      replicas: 3
      config:
        key: value
```

## Multiple Resources

```yaml
resources:
  - apiVersion: example.com/v1
    kind: Widget
    metadata:
      name: widget-a
    spec:
      size: large

  - apiVersion: example.com/v1
    kind: Widget
    metadata:
      name: widget-b
    spec:
      size: small
```

## Use Cases

- Deploy CRDs from operators that don't have Helm charts
- Manage platform-level resources alongside application charts
- Prototype new resource types before building dedicated charts
