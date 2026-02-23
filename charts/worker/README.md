# worker

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| args | list | `[]` |  |
| command | list | `[]` |  |
| commonAnnotations | object | `{}` |  |
| commonEnvVars | bool | `false` |  |
| commonLabels | object | `{}` |  |
| configMap.annotations | object | `{}` |  |
| configMap.binaryData | object | `{}` |  |
| configMap.data | object | `{}` |  |
| configMap.enabled | bool | `false` |  |
| configMap.envFrom | bool | `false` |  |
| configMap.labels | object | `{}` |  |
| configMap.mountPath | string | `""` |  |
| configMap.subPath | string | `""` |  |
| deploymentEnabled | bool | `true` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| externalSecrets | object | `{}` |  |
| extraConfigMaps | object | `{}` |  |
| extraEnvFrom | list | `[]` |  |
| extraObjects | list | `[]` |  |
| extraSecrets | object | `{}` |  |
| extraTargetGroupBindings | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| gateway.httpRoute.annotations | object | `{}` |  |
| gateway.httpRoute.enabled | bool | `false` |  |
| gateway.httpRoute.extraRoutes | object | `{}` |  |
| gateway.httpRoute.hostnames | list | `[]` |  |
| gateway.httpRoute.labels | object | `{}` |  |
| gateway.httpRoute.parentRefs | list | `[]` |  |
| gateway.httpRoute.rules | list | `[]` |  |
| gateway.referenceGrant.annotations | object | `{}` |  |
| gateway.referenceGrant.enabled | bool | `false` |  |
| gateway.referenceGrant.extraGrants | object | `{}` |  |
| gateway.referenceGrant.from | list | `[]` |  |
| gateway.referenceGrant.labels | object | `{}` |  |
| gateway.referenceGrant.to | list | `[]` |  |
| gateway.tcpRoute.annotations | object | `{}` |  |
| gateway.tcpRoute.enabled | bool | `false` |  |
| gateway.tcpRoute.extraRoutes | object | `{}` |  |
| gateway.tcpRoute.labels | object | `{}` |  |
| gateway.tcpRoute.parentRefs | list | `[]` |  |
| gateway.tcpRoute.rules | list | `[]` |  |
| global.image.registry | string | `""` |  |
| hpa.behavior | object | `{}` |  |
| hpa.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.metrics[0].resource.name | string | `"cpu"` |  |
| hpa.metrics[0].resource.target.averageUtilization | int | `80` |  |
| hpa.metrics[0].resource.target.type | string | `"Utilization"` |  |
| hpa.metrics[0].type | string | `"Resource"` |  |
| hpa.minReplicas | int | `1` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"busybox"` |  |
| image.tag | string | `"1.36"` |  |
| imagePullSecrets | list | `[]` |  |
| initContainers | list | `[]` |  |
| jobs | object | `{}` |  |
| lifecycle | object | `{}` |  |
| livenessProbe | object | `{}` |  |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| networkPolicy.egress | list | `[]` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress | list | `[]` |  |
| networkPolicy.policyTypes | list | `[]` |  |
| pod.activeDeadlineSeconds | string | `""` |  |
| pod.annotations | object | `{}` |  |
| pod.dnsConfig | object | `{}` |  |
| pod.dnsPolicy | string | `""` |  |
| pod.hostAliases | list | `[]` |  |
| pod.hostIPC | bool | `false` |  |
| pod.hostNetwork | bool | `false` |  |
| pod.hostPID | bool | `false` |  |
| pod.hostname | string | `""` |  |
| pod.labels | object | `{}` |  |
| pod.priority | string | `""` |  |
| pod.priorityClassName | string | `""` |  |
| pod.resources | object | `{}` |  |
| pod.restartPolicy | string | `""` |  |
| pod.runtimeClassName | string | `""` |  |
| pod.schedulerName | string | `""` |  |
| pod.securityContext | object | `{}` |  |
| pod.terminationGracePeriodSeconds | int | `30` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podDisruptionBudget.unhealthyPodEvictionPolicy | string | `""` |  |
| ports | list | `[]` |  |
| rbac.aggregationRule | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.enabled | bool | `false` |  |
| rbac.extraRoles | object | `{}` |  |
| rbac.labels | object | `{}` |  |
| rbac.roleRef | string | `""` |  |
| rbac.rules | list | `[]` |  |
| rbac.subjects | list | `[]` |  |
| rbac.type | string | `"Role"` |  |
| readinessProbe | object | `{}` |  |
| replicas | int | `1` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| scheduling.affinity | object | `{}` |  |
| scheduling.nodeSelector | object | `{}` |  |
| scheduling.tolerations | list | `[]` |  |
| scheduling.topologySpreadConstraints[0].maxSkew | int | `1` |  |
| scheduling.topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| scheduling.topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| scheduling.topologySpreadConstraints[1].maxSkew | int | `1` |  |
| scheduling.topologySpreadConstraints[1].topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| scheduling.topologySpreadConstraints[1].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| secret.annotations | object | `{}` |  |
| secret.data | object | `{}` |  |
| secret.enabled | bool | `false` |  |
| secret.envFrom | bool | `false` |  |
| secret.labels | object | `{}` |  |
| secret.mountPath | string | `""` |  |
| secret.stringData | object | `{}` |  |
| secret.subPath | string | `""` |  |
| secret.type | string | `"Opaque"` |  |
| security.defaultContainerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| security.defaultContainerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| security.defaultContainerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| security.defaultContainerSecurityContext.runAsNonRoot | bool | `true` |  |
| security.defaultContainerSecurityContext.runAsUser | int | `1000` |  |
| security.defaultContainerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| security.defaultPodSecurityContext.fsGroup | int | `1000` |  |
| security.defaultPodSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| security.defaultPodSecurityContext.runAsGroup | int | `1000` |  |
| security.defaultPodSecurityContext.runAsNonRoot | bool | `true` |  |
| security.defaultPodSecurityContext.runAsUser | int | `1000` |  |
| security.defaultPodSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| security.podSecurityStandards.audit | string | `""` |  |
| security.podSecurityStandards.enabled | bool | `false` |  |
| security.podSecurityStandards.enforce | string | `""` |  |
| security.podSecurityStandards.warn | string | `""` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `false` |  |
| service.labels | object | `{}` |  |
| service.ports | list | `[]` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.labels | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| sidecarContainers | list | `[]` |  |
| startupProbe | object | `{}` |  |
| strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| targetGroupBinding.annotations | object | `{}` |  |
| targetGroupBinding.enabled | bool | `false` |  |
| targetGroupBinding.ipAddressType | string | `""` |  |
| targetGroupBinding.labels | object | `{}` |  |
| targetGroupBinding.networking | object | `{}` |  |
| targetGroupBinding.serviceRef.name | string | `""` |  |
| targetGroupBinding.serviceRef.port | string | `"http"` |  |
| targetGroupBinding.targetGroupARN | string | `""` |  |
| targetGroupBinding.targetType | string | `""` |  |
| volumes.emptyDir | object | `{}` |  |
| volumes.extra | list | `[]` |  |
| volumes.extraMounts | list | `[]` |  |
| volumes.hostPath | object | `{}` |  |
| volumes.persistent | object | `{}` |  |
| workloadAnnotations | object | `{}` |  |
| workloadLabels | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.0.0](https://github.com/norwoodj/helm-docs/releases/v1.0.0)
