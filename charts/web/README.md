# web

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying HTTP-facing web applications to Kubernetes.
Includes Deployment, Service, Ingress (enabled by default), HPA, PDB, and ServiceAccount.
Designed for web applications that need external traffic exposure.

## Overview

The **web** chart is an opinionated Helm chart for deploying external-facing web applications. It uses the same schema as the `generic` chart but comes with sensible defaults pre-configured for public web workloads, including ALB ingress.

## Use Cases

- **Public websites** - Frontend applications accessible from the internet
- **Web APIs** - External-facing REST APIs
- **Single Page Applications** - React, Vue, Angular apps served via nginx/CDN
- **Customer portals** - User-facing web interfaces

## Key Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `service.enabled` | `true` | ClusterIP service |
| `ingress.enabled` | `true` | ALB ingress enabled |
| `ingress.className` | `alb` | AWS ALB Ingress Controller |
| `ports[0]` | `8080/http` | Standard HTTP port |
| `livenessProbe` | `/health` | Pre-configured health endpoint |
| `readinessProbe` | `/health` | Pre-configured health endpoint |

## Quick Start

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update

helm install my-web dnd-it/web \
  --set image.repository=myorg/frontend \
  --set image.tag=v1.0.0 \
  --set ingress.hosts[0].host=myapp.example.com
```

## Examples

### Basic Web Application

```yaml
image:
  repository: myorg/frontend
  tag: "v2.0.0"

replicas: 2

ingress:
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Web App with SSL

```yaml
image:
  repository: myorg/webapp
  tag: "v1.5.0"

ingress:
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:123456789:certificate/abc123
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
  hosts:
    - host: secure.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Web App with Custom ALB Group

```yaml
image:
  repository: myorg/portal
  tag: "v3.0.0"

replicas: 3

ingress:
  annotations:
    alb.ingress.kubernetes.io/group.name: public-apps
    alb.ingress.kubernetes.io/group.order: "10"
    alb.ingress.kubernetes.io/healthcheck-path: /api/health
  hosts:
    - host: portal.example.com
      paths:
        - path: /
          pathType: Prefix

hpa:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60
```

### Static Site with nginx

```yaml
image:
  repository: myorg/static-site
  tag: "v1.0.0"

ports:
  - name: http
    containerPort: 80

livenessProbe:
  httpGet:
    path: /
    port: http

readinessProbe:
  httpGet:
    path: /
    port: http

ingress:
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/healthcheck-port: "80"
  hosts:
    - host: docs.example.com
      paths:
        - path: /
          pathType: Prefix
```

## ALB Annotations Reference

Common ALB annotations pre-configured or frequently used:

```yaml
ingress:
  annotations:
    # Scheme
    alb.ingress.kubernetes.io/scheme: internet-facing  # or internal
    alb.ingress.kubernetes.io/target-type: ip

    # SSL
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...
    alb.ingress.kubernetes.io/ssl-redirect: "443"

    # Health checks
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/healthcheck-port: "8080"
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP

    # Grouping
    alb.ingress.kubernetes.io/group.name: shared-alb
    alb.ingress.kubernetes.io/group.order: "100"
```

## Comparison with API Chart

| Feature | web | api |
|---------|-----|-----|
| Service | Enabled | Enabled |
| Ingress | **Enabled** | Disabled |
| ALB Annotations | Pre-configured | None |
| Health Probes | Pre-configured | Pre-configured |

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
| hpa.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.minReplicas | int | `2` |  |
| hpa.targetCPUUtilizationPercentage | int | `80` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `""` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations."alb.ingress.kubernetes.io/group.name" | string | `"default"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/healthcheck-interval-seconds" | string | `"15"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/healthcheck-path" | string | `"/health"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/healthcheck-port" | string | `"8080"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/healthcheck-protocol" | string | `"HTTP"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/healthcheck-timeout-seconds" | string | `"5"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/healthy-threshold-count" | string | `"2"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/scheme" | string | `"internet-facing"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/target-type" | string | `"ip"` |  |
| ingress.annotations."alb.ingress.kubernetes.io/unhealthy-threshold-count" | string | `"3"` |  |
| ingress.className | string | `"alb"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hosts | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| initContainers | list | `[]` |  |
| jobs | object | `{}` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/health"` |  |
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
| pod.labels | object | `{}` |  |
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
| readinessProbe.httpGet.path | string | `"/health"` |  |
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
| serviceAccount.labels | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.httpGet.path | string | `"/health"` |  |
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
Autogenerated from chart metadata using [helm-docs v1.0.0](https://github.com/norwoodj/helm-docs/releases/v1.0.0)
