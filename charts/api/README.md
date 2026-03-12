# api

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying internal API services to Kubernetes.
Includes Deployment, Service (enabled by default), HPA, PDB, and ServiceAccount.
Designed for internal services that communicate with other services within the cluster.
Ingress is disabled by default for internal-only services.

## Overview

The **api** chart is an opinionated Helm chart for deploying internal API services. It uses the same schema as the `generic` chart but comes with sensible defaults pre-configured for backend API workloads.

## Use Cases

- **Internal microservices** - Backend APIs that communicate with other services
- **REST/gRPC APIs** - Services exposing HTTP or gRPC endpoints internally
- **Backend workers with endpoints** - Services that need to be reachable but not exposed externally

## Key Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `service.enabled` | `true` | ClusterIP service for internal communication |
| `ingress.enabled` | `false` | No external exposure by default |
| `ports[0]` | `8080/http` | Standard HTTP port |
| `livenessProbe` | `/health` | Pre-configured health endpoint |
| `readinessProbe` | `/health` | Pre-configured health endpoint |
| `resources.requests` | `100m/128Mi` | Conservative resource requests |

## Quick Start

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update

helm install my-api dnd-it/api \
  --set image.repository=myorg/my-api \
  --set image.tag=v1.0.0
```

## Examples

### Basic Internal API

```yaml
image:
  repository: myorg/user-service
  tag: "v2.1.0"

replicas: 2

env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: url
```

### API with Custom Health Endpoint

```yaml
image:
  repository: myorg/order-service
  tag: "v1.5.0"

ports:
  - name: http
    containerPort: 3000

livenessProbe:
  httpGet:
    path: /api/health
    port: http
  initialDelaySeconds: 15

readinessProbe:
  httpGet:
    path: /api/ready
    port: http
```

### API with HPA

```yaml
image:
  repository: myorg/catalog-service
  tag: "v3.0.0"

replicas: 2

hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

resources:
  limits:
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi
```

### API with External Secrets

```yaml
image:
  repository: myorg/payment-service
  tag: "v1.0.0"

externalSecrets:
  payment-credentials:
    enabled: true
    secretStoreRef:
      name: aws-secretsmanager
      kind: ClusterSecretStore
    data:
      - secretKey: API_KEY
        remoteRef:
          key: prod/payment/api-key
```

## Comparison with Generic Chart

| Feature | api | generic |
|---------|-----|---------|
| Service | Enabled | Disabled |
| Ingress | Disabled | Disabled |
| Health Probes | Pre-configured | Empty |
| Resource Defaults | Set | Empty |
| Topology Spread | Configured | Empty |

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
| configMap.envFrom | bool | `true` |  |
| gateway.httpRoute.enabled | bool | `true` |  |
| gateway.httpRoute.hostnames | list | `[]` |  |
| gateway.httpRoute.parentRefs | list | `[]` |  |
| gateway.httpRoute.rules | list | `[]` |  |
| gateway.loadBalancerConfiguration.enabled | bool | `true` |  |
| gateway.loadBalancerConfiguration.ipAddressType | string | `"ipv4"` |  |
| gateway.loadBalancerConfiguration.scheme | string | `"internet-facing"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckIntervalSeconds | string | `"15"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckPath | string | `"/readyz"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckPort | string | `"8080"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckProtocol | string | `"HTTP"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckTimeoutSeconds | string | `"5"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthyThresholdCount | string | `"2"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.unhealthyThresholdCount | string | `"3"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.protocolVersion | string | `"HTTP1"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.targetType | string | `"ip"` |  |
| gateway.targetGroupConfiguration.enabled | bool | `true` |  |
| hpa.minReplicas | int | `2` |  |
| image.repository | string | `""` |  |
| image.tag | string | `""` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/livez"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| ports[0].containerPort | int | `8080` |  |
| ports[0].name | string | `"http"` |  |
| ports[0].protocol | string | `"TCP"` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| scheduling.nodeSelector."kubernetes.io/arch" | string | `"amd64"` |  |
| scheduling.topologySpreadConstraints[0].maxSkew | int | `1` |  |
| scheduling.topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| scheduling.topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| scheduling.topologySpreadConstraints[1].maxSkew | int | `1` |  |
| scheduling.topologySpreadConstraints[1].topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| scheduling.topologySpreadConstraints[1].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| service.enabled | bool | `true` |  |
| service.type | string | `"ClusterIP"` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.httpGet.path | string | `"/readyz"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `2` |  |
| startupProbe.timeoutSeconds | int | `3` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.1.0](https://github.com/norwoodj/helm-docs/releases/v1.1.0)
