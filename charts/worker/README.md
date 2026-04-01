# worker

![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying background worker processes to Kubernetes.
Includes Deployment, HPA, PDB, and ServiceAccount.
Designed for background processing workloads that don't expose HTTP endpoints.
No service or ingress by default.

## Overview

The **worker** chart is an opinionated Helm chart for deploying background processing workloads. It uses the same schema as the `generic` chart but comes with sensible defaults for non-HTTP workers that don't need service exposure.

## Use Cases

- **Message queue consumers** - Workers processing messages from SQS, RabbitMQ, Kafka
- **Background job processors** - Celery workers, Sidekiq, Bull queues
- **Data pipeline workers** - ETL processors, stream consumers
- **Async task handlers** - Long-running background tasks

## Key Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `service.enabled` | `false` | No service (workers don't serve HTTP) |
| `ingress.enabled` | `false` | No ingress |
| `ports` | `[]` | No ports exposed |
| `livenessProbe` | `{}` | No HTTP probes (configure if needed) |
| `readinessProbe` | `{}` | No HTTP probes (configure if needed) |
| `resources.requests` | `100m/128Mi` | Conservative defaults |

## Quick Start

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update

helm install my-worker dnd-it/worker \
  --set image.repository=myorg/queue-worker \
  --set image.tag=v1.0.0
```

## Examples

### Basic Queue Worker

```yaml
image:
  repository: myorg/sqs-consumer
  tag: "v1.2.0"

replicas: 3

command: ["python"]
args: ["worker.py"]

env:
  - name: QUEUE_URL
    value: "https://sqs.us-east-1.amazonaws.com/123456789/my-queue"
  - name: CONCURRENCY
    value: "10"
```

### Celery Worker

```yaml
image:
  repository: myorg/celery-app
  tag: "v2.0.0"

replicas: 5

command: ["celery"]
args: ["-A", "tasks", "worker", "--loglevel=info", "--concurrency=4"]

env:
  - name: CELERY_BROKER_URL
    valueFrom:
      secretKeyRef:
        name: celery-secrets
        key: broker-url

resources:
  limits:
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### Kafka Consumer

```yaml
image:
  repository: myorg/kafka-consumer
  tag: "v1.0.0"

replicas: 3

env:
  - name: KAFKA_BROKERS
    value: "kafka-0:9092,kafka-1:9092,kafka-2:9092"
  - name: CONSUMER_GROUP
    value: "my-consumer-group"
  - name: TOPICS
    value: "events,notifications"

# Scale based on consumer lag (requires KEDA or custom metrics)
hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
```

### Worker with Exec Probe

```yaml
image:
  repository: myorg/batch-processor
  tag: "v1.5.0"

replicas: 2

command: ["python", "processor.py"]

# Use exec probe for non-HTTP workers
livenessProbe:
  exec:
    command:
      - cat
      - /tmp/healthy
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  exec:
    command:
      - cat
      - /tmp/ready
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Worker with Metrics Sidecar

```yaml
image:
  repository: myorg/worker
  tag: "v1.0.0"

replicas: 3

# Enable service only for metrics scraping
service:
  enabled: true
  ports:
    - name: metrics
      port: 9090
      targetPort: 9090

ports:
  - name: metrics
    containerPort: 9090

# Add prometheus annotations
pod:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
```

## Comparison with Other Charts

| Feature | worker | api | web |
|---------|--------|-----|-----|
| Service | **Disabled** | Enabled | Enabled |
| Ingress | Disabled | Disabled | Enabled |
| Ports | **None** | 8080 | 8080 |
| Health Probes | **Empty** | Configured | Configured |

**Homepage:** <https://github.com/dnd-it/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <abc@abc.com> |  |

## Source Code

* <https://github.com/dnd-it/helm-charts>

## Requirements

Kubernetes: `>=1.32.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 1.x.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `""` |  |
| image.tag | string | `""` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| scheduling.topologySpreadConstraints[0].maxSkew | int | `1` |  |
| scheduling.topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| scheduling.topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| scheduling.topologySpreadConstraints[1].maxSkew | int | `1` |  |
| scheduling.topologySpreadConstraints[1].topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| scheduling.topologySpreadConstraints[1].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| service.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.3.0](https://github.com/norwoodj/helm-docs/releases/v1.3.0)
