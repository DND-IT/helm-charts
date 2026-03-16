# Pod Resources

Starting with Kubernetes 1.32, resource requests and limits can be defined at the **pod level** instead of per-container. This is the default resource model in these charts.

## Pod-level vs Container-level

| | Pod Resources | Container Resources |
|---|---|---|
| **Scope** | Shared across all containers in the pod | Per-container |
| **Key** | `resources:` (top-level) | `container.resources:` |
| **K8s API** | `spec.resources` | `spec.containers[].resources` |
| **Since** | Kubernetes 1.32 | Always |

## Default Behavior

Top-level `resources:` renders at the **pod spec level**:

```yaml
# values.yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 256Mi
```

Produces:

```yaml
# Rendered manifest
spec:
  template:
    spec:
      resources:           # Pod-level
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          memory: 256Mi
      containers:
        - name: main
          # No container-level resources
```

## Container-level Resources

If you need container-level resources (e.g., for multi-container pods where each container needs different limits):

```yaml
# values.yaml
container:
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      memory: 512Mi
```

Produces:

```yaml
# Rendered manifest
spec:
  template:
    spec:
      containers:
        - name: main
          resources:       # Container-level
            requests:
              cpu: 200m
              memory: 256Mi
            limits:
              memory: 512Mi
```

## Using Both

You can set both pod-level and container-level resources. Pod-level resources set the overall budget, while container-level resources constrain individual containers:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 512Mi

container:
  resources:
    requests:
      cpu: 300m
      memory: 256Mi
```

## Init and Sidecar Containers

Init containers and sidecar containers always use **container-level** resources defined in their own spec:

```yaml
initContainers:
  - name: migrate
    image: my-app:1.0.0
    command: ["python", "-m", "migrate"]
    resources:
      requests:
        cpu: 100m
        memory: 128Mi

sidecarContainers:
  - name: proxy
    image: envoyproxy/envoy:v1.30
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
```

## Chart Defaults

Each wrapper chart sets pod-level resource defaults:

| Chart | CPU Request | Memory Request | Memory Limit |
|-------|-------------|----------------|--------------|
| web | 100m | 128Mi | - |
| api | 100m | 128Mi | - |
| worker | 100m | 128Mi | 256Mi |
| task | 100m | 128Mi | - |
| generic | 100m | 128Mi | 256Mi |
