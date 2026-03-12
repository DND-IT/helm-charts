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
| args | list | `[]` |  |
| command | list | `[]` |  |
| commonAnnotations | object | `{}` |  |
| commonEnvVars | bool | `false` |  |
| commonLabels | object | `{}` |  |
| configMap.annotations | object | `{}` |  |
| configMap.binaryData | object | `{}` |  |
| configMap.data | object | `{}` |  |
| configMap.enabled | bool | `false` |  |
| configMap.envFrom | bool | `true` |  |
| configMap.labels | object | `{}` |  |
| configMap.mountPath | string | `""` |  |
| configMap.subPath | string | `""` |  |
| deploymentEnabled | bool | `true` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| externalSecrets | object | `{}` |  |
| extraConfigMaps | object | `{}` |  |
| extraContainers | list | `[]` |  |
| extraEnvFrom | list | `[]` |  |
| extraObjects | list | `[]` |  |
| extraSecrets | object | `{}` |  |
| extraTargetGroupBindings | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| gateway.grpcRoute.annotations | object | `{}` |  |
| gateway.grpcRoute.enabled | bool | `false` |  |
| gateway.grpcRoute.extraRoutes | object | `{}` |  |
| gateway.grpcRoute.hostnames | list | `[]` |  |
| gateway.grpcRoute.labels | object | `{}` |  |
| gateway.grpcRoute.parentRefs | list | `[]` |  |
| gateway.grpcRoute.rules | list | `[]` |  |
| gateway.httpRoute.annotations | object | `{}` |  |
| gateway.httpRoute.enabled | bool | `false` |  |
| gateway.httpRoute.extraRoutes | object | `{}` |  |
| gateway.httpRoute.hostnames | list | `[]` |  |
| gateway.httpRoute.labels | object | `{}` |  |
| gateway.httpRoute.parentRefs | list | `[]` |  |
| gateway.httpRoute.rules | list | `[]` |  |
| gateway.listenerRuleConfiguration.actions | list | `[]` |  |
| gateway.listenerRuleConfiguration.annotations | object | `{}` |  |
| gateway.listenerRuleConfiguration.conditions | list | `[]` |  |
| gateway.listenerRuleConfiguration.enabled | bool | `false` |  |
| gateway.listenerRuleConfiguration.labels | object | `{}` |  |
| gateway.listenerRuleConfiguration.tags | object | `{}` |  |
| gateway.listenerRuleConfiguration.targetRef | object | `{}` |  |
| gateway.loadBalancerConfiguration.annotations | object | `{}` |  |
| gateway.loadBalancerConfiguration.enabled | bool | `false` |  |
| gateway.loadBalancerConfiguration.ipAddressType | string | `""` |  |
| gateway.loadBalancerConfiguration.labels | object | `{}` |  |
| gateway.loadBalancerConfiguration.listenerConfigurations | list | `[]` |  |
| gateway.loadBalancerConfiguration.loadBalancerAttributes | list | `[]` |  |
| gateway.loadBalancerConfiguration.loadBalancerName | string | `""` |  |
| gateway.loadBalancerConfiguration.loadBalancerSubnets | list | `[]` |  |
| gateway.loadBalancerConfiguration.scheme | string | `""` |  |
| gateway.loadBalancerConfiguration.securityGroups | list | `[]` |  |
| gateway.loadBalancerConfiguration.shieldConfiguration | object | `{}` |  |
| gateway.loadBalancerConfiguration.sourceRanges | list | `[]` |  |
| gateway.loadBalancerConfiguration.tags | object | `{}` |  |
| gateway.loadBalancerConfiguration.wafV2 | object | `{}` |  |
| gateway.referenceGrant.annotations | object | `{}` |  |
| gateway.referenceGrant.enabled | bool | `false` |  |
| gateway.referenceGrant.extraGrants | object | `{}` |  |
| gateway.referenceGrant.from | list | `[]` |  |
| gateway.referenceGrant.labels | object | `{}` |  |
| gateway.referenceGrant.to | list | `[]` |  |
| gateway.targetGroupConfiguration.annotations | object | `{}` |  |
| gateway.targetGroupConfiguration.defaultConfiguration | object | `{}` |  |
| gateway.targetGroupConfiguration.enabled | bool | `false` |  |
| gateway.targetGroupConfiguration.labels | object | `{}` |  |
| gateway.targetGroupConfiguration.routeConfigurations | list | `[]` |  |
| gateway.targetGroupConfiguration.targetReference | object | `{}` |  |
| gateway.tcpRoute.annotations | object | `{}` |  |
| gateway.tcpRoute.enabled | bool | `false` |  |
| gateway.tcpRoute.extraRoutes | object | `{}` |  |
| gateway.tcpRoute.labels | object | `{}` |  |
| gateway.tcpRoute.parentRefs | list | `[]` |  |
| gateway.tcpRoute.rules | list | `[]` |  |
| gateway.tlsRoute.annotations | object | `{}` |  |
| gateway.tlsRoute.enabled | bool | `false` |  |
| gateway.tlsRoute.extraRoutes | object | `{}` |  |
| gateway.tlsRoute.hostnames | list | `[]` |  |
| gateway.tlsRoute.labels | object | `{}` |  |
| gateway.tlsRoute.parentRefs | list | `[]` |  |
| gateway.tlsRoute.rules | list | `[]` |  |
| gateway.udpRoute.annotations | object | `{}` |  |
| gateway.udpRoute.enabled | bool | `false` |  |
| gateway.udpRoute.extraRoutes | object | `{}` |  |
| gateway.udpRoute.labels | object | `{}` |  |
| gateway.udpRoute.parentRefs | list | `[]` |  |
| gateway.udpRoute.rules | list | `[]` |  |
| global.image.registry | string | `""` |  |
| hpa.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.minReplicas | int | `2` |  |
| hpa.targetCPUUtilizationPercentage | int | `80` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `""` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.enabled | bool | `false` |  |
| initContainers | list | `[]` |  |
| jobs | object | `{}` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/livez"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| networkPolicy.egress | list | `[]` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress | list | `[]` |  |
| networkPolicy.policyTypes | list | `[]` |  |
| pod.annotations | object | `{}` |  |
| pod.labels."admission.datadoghq.com/enabled" | string | `"true"` |  |
| pod.resources | object | `{}` |  |
| pod.securityContext | object | `{}` |  |
| pod.terminationGracePeriodSeconds | int | `30` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| ports[0].containerPort | int | `8080` |  |
| ports[0].name | string | `"http"` |  |
| ports[0].protocol | string | `"TCP"` |  |
| rbac.aggregationRule | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.enabled | bool | `false` |  |
| rbac.extraRoles | object | `{}` |  |
| rbac.labels | object | `{}` |  |
| rbac.roleRef | string | `""` |  |
| rbac.rules | list | `[]` |  |
| rbac.subjects | list | `[]` |  |
| rbac.type | string | `"Role"` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicas | int | `1` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| revisionHistoryLimit | int | `2` |  |
| scheduling.affinity | object | `{}` |  |
| scheduling.nodeSelector."kubernetes.io/arch" | string | `"amd64"` |  |
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
| securityContext | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.ports | list | `[]` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.httpGet.path | string | `"/readyz"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `2` |  |
| startupProbe.timeoutSeconds | int | `3` |  |
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
| volumes.configMap | object | `{}` |  |
| volumes.emptyDir | object | `{}` |  |
| volumes.persistent | object | `{}` |  |
| volumes.projected | object | `{}` |  |
| volumes.secret | object | `{}` |  |
| workloadAnnotations | object | `{}` |  |
| workloadLabels | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.1.0](https://github.com/norwoodj/helm-docs/releases/v1.1.0)
