# web

![Version: 1.2.4](https://img.shields.io/badge/Version-1.2.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| configMap.envFrom | bool | `true` |  |
| gateway.httpRoute.enabled | bool | `true` |  |
| gateway.httpRoute.hostnames | list | `[]` |  |
| gateway.httpRoute.parentRefs | list | `[]` |  |
| gateway.httpRoute.rules | list | `[]` |  |
| gateway.loadBalancerConfiguration.enabled | bool | `false` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckInterval | int | `15` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckPath | string | `"/readyz"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckPort | string | `"8080"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthCheckProtocol | string | `"HTTP"` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.healthyThresholdCount | int | `2` |  |
| gateway.targetGroupConfiguration.defaultConfiguration.healthCheckConfig.unhealthyThresholdCount | int | `3` |  |
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
Autogenerated from chart metadata using [helm-docs v1.2.4](https://github.com/norwoodj/helm-docs/releases/v1.2.4)
