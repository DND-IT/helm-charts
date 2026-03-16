# Worker Chart

Opinionated chart for **background processing workloads**. No service or networking is configured. Designed for queue consumers, stream processors, and other long-running background tasks.

## What's Pre-configured

| Setting | Default |
|---------|---------|
| Service | Disabled |
| Resources | 100m CPU, 128Mi memory request, 256Mi memory limit (pod-level) |
| Topology spread | Spread across nodes and zones |
| Probes | None |
| Ports | None |

## Minimal Example

```yaml
image:
  repository: my-registry/my-worker
  tag: "1.0.0"

command: ["python"]
args: ["-m", "worker"]
```

## Full Example

```yaml
image:
  repository: my-registry/my-worker
  tag: "1.0.0"

replicas: 3

command: ["python"]
args: ["-m", "worker", "--queue", "high-priority"]

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    memory: 512Mi

env:
  - name: QUEUE_URL
    valueFrom:
      secretKeyRef:
        name: sqs-credentials
        key: queue-url
  - name: CONCURRENCY
    value: "5"

hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: External
      external:
        metric:
          name: sqs_queue_depth
        target:
          type: AverageValue
          averageValue: "10"

podDisruptionBudget:
  enabled: true
  minAvailable: 1

pod:
  terminationGracePeriodSeconds: 300  # Allow in-flight messages to finish
```

## Adding Health Probes

Workers don't have probes by default since they typically don't serve HTTP. If your worker exposes a health endpoint:

```yaml
ports:
  - name: health
    containerPort: 8081

livenessProbe:
  httpGet:
    path: /healthz
    port: health
```
