# app

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A generic, flexible Helm chart for deploying applications on Kubernetes. This chart follows best practices and provides comprehensive configuration options for most application deployment scenarios.

## Features

- **Deployment**: Configurable deployment with rolling updates, resource limits, and health checks
- **Service**: Flexible service configuration with multiple port support
- **Ingress**: Full ingress support with TLS and multiple hosts
- **Persistence**: PersistentVolumeClaim support for stateful applications
- **Scaling**: Horizontal Pod Autoscaler integration
- **Security**: RBAC, ServiceAccount, NetworkPolicy, and PodSecurityContext support
- **Monitoring**: ServiceMonitor for Prometheus integration
- **High Availability**: Pod Disruption Budget support
- **Flexibility**: ConfigMap, Secret, and extra objects support

## Quick Start

### Add the Helm Repository

```bash
helm repo add app https://your-repo.example.com
helm repo update
```

### Install the Chart

```bash
# Basic installation
helm install my-app app/app

# With custom values
helm install my-app app/app -f values.yaml

# With inline values
helm install my-app app/app \
  --set image.repository=nginx \
  --set image.tag=1.21 \
  --set service.port=80
```

## Configuration

### Core Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.name` | Application name | `""` (chart name) |
| `app.version` | Application version | `""` (chart appVersion) |
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Container image tag | `1.21` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.enabled` | Enable deployment | `true` |
| `deployment.replicas` | Number of replicas | `1` |
| `deployment.strategy.type` | Deployment strategy | `RollingUpdate` |
| `deployment.resources` | Resource limits and requests | `{}` |
| `deployment.nodeSelector` | Node selector | `{}` |
| `deployment.tolerations` | Pod tolerations | `[]` |
| `deployment.affinity` | Pod affinity rules | `{}` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.enabled` | Enable service | `true` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Target port | `http` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `false` |
| `persistence.size` | Storage size | `8Gi` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.mountPath` | Mount path in container | `/data` |

### Health Checks

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.livenessProbe.enabled` | Enable liveness probe | `false` |
| `deployment.readinessProbe.enabled` | Enable readiness probe | `false` |
| `deployment.startupProbe.enabled` | Enable startup probe | `false` |

### Autoscaling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | CPU target | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Memory target | `80` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.enabled` | Enable service account | `true` |
| `serviceAccount.create` | Create service account | `true` |
| `rbac.enabled` | Enable RBAC | `false` |
| `networkPolicy.enabled` | Enable network policy | `false` |
| `podDisruptionBudget.enabled` | Enable PDB | `false` |

### Monitoring

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `serviceMonitor.interval` | Scrape interval | `30s` |
| `serviceMonitor.path` | Metrics path | `/metrics` |

## Examples

### Basic Web Application

```yaml
image:
  repository: nginx
  tag: "1.21"

service:
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

deployment:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi
```

### Application with Database

```yaml
image:
  repository: myapp
  tag: "v1.0.0"

persistence:
  enabled: true
  size: 20Gi
  mountPath: /var/lib/data

configMap:
  enabled: true
  data:
    database.conf: |
      host=postgres.default.svc.cluster.local
      port=5432

secret:
  enabled: true
  stringData:
    db-password: "supersecret"

deployment:
  env:
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: myapp-config
          key: database.host
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: myapp-secret
          key: db-password
```

### High Availability Setup

```yaml
deployment:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

podDisruptionBudget:
  enabled: true
  minAvailable: 2

deployment:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                    - myapp
            topologyKey: kubernetes.io/hostname
```

## Upgrading

### From v0.x to v1.x

- Update values file structure according to new schema
- Review breaking changes in CHANGELOG.md

## Development

### Testing

```bash
# Lint the chart
helm lint .

# Test template rendering
helm template test-release . -f values-example.yaml

# Test installation
helm install test-release . --dry-run --debug
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This chart is licensed under the MIT License. See LICENSE file for details.

## Support

- Documentation: [Chart Documentation](https://your-docs.example.com)
- Issues: [GitHub Issues](https://github.com/your-org/app-chart/issues)
- Discussions: [GitHub Discussions](https://github.com/your-org/app-chart/discussions)

**Homepage:** <https://github.com/dnd-it/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <abc@abc.com> |  |

## Source Code

* <https://github.com/dnd-it/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| app.name | string | `""` |  |
| app.version | string | `""` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| configMap.annotations | object | `{}` |  |
| configMap.data | object | `{}` |  |
| configMap.enabled | bool | `false` |  |
| configMap.labels | object | `{}` |  |
| deployment.affinity | object | `{}` |  |
| deployment.args | list | `[]` |  |
| deployment.command | list | `[]` |  |
| deployment.enabled | bool | `true` |  |
| deployment.env | list | `[]` |  |
| deployment.envFrom | list | `[]` |  |
| deployment.livenessProbe.enabled | bool | `false` |  |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.httpGet.path | string | `"/"` |  |
| deployment.livenessProbe.httpGet.port | string | `"http"` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `5` |  |
| deployment.nodeSelector | object | `{}` |  |
| deployment.podAnnotations | object | `{}` |  |
| deployment.podLabels | object | `{}` |  |
| deployment.podSecurityContext | object | `{}` |  |
| deployment.readinessProbe.enabled | bool | `false` |  |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.httpGet.path | string | `"/"` |  |
| deployment.readinessProbe.httpGet.port | string | `"http"` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `5` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `5` |  |
| deployment.replicas | int | `1` |  |
| deployment.resources | object | `{}` |  |
| deployment.securityContext | object | `{}` |  |
| deployment.startupProbe.enabled | bool | `false` |  |
| deployment.startupProbe.failureThreshold | int | `30` |  |
| deployment.startupProbe.httpGet.path | string | `"/"` |  |
| deployment.startupProbe.httpGet.port | string | `"http"` |  |
| deployment.startupProbe.initialDelaySeconds | int | `10` |  |
| deployment.startupProbe.periodSeconds | int | `10` |  |
| deployment.startupProbe.successThreshold | int | `1` |  |
| deployment.startupProbe.timeoutSeconds | int | `5` |  |
| deployment.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| deployment.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| deployment.strategy.type | string | `"RollingUpdate"` |  |
| deployment.tolerations | list | `[]` |  |
| extraObjects | list | `[]` |  |
| global.annotations | object | `{}` |  |
| global.labels | object | `{}` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.repository | string | `"traefik/whoami"` |  |
| image.tag | string | `"latest"` |  |
| ingress.enabled | bool | `false` |  |
| initContainers | list | `[]` |  |
| networkPolicy.egress | list | `[]` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress | list | `[]` |  |
| networkPolicy.policyTypes | list | `[]` |  |
| pdb.enabled | bool | `false` |  |
| pdb.minAvailable | int | `1` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `false` |  |
| persistence.labels | object | `{}` |  |
| persistence.mountPath | string | `"/data"` |  |
| persistence.size | string | `"8Gi"` |  |
| persistence.storageClass | string | `""` |  |
| persistence.subPath | string | `""` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| rbac.enabled | bool | `false` |  |
| rbac.rules | list | `[]` |  |
| secret.annotations | object | `{}` |  |
| secret.data | object | `{}` |  |
| secret.enabled | bool | `false` |  |
| secret.labels | object | `{}` |  |
| secret.stringData | object | `{}` |  |
| secret.type | string | `"Opaque"` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.labels | object | `{}` |  |
| service.port | int | `80` |  |
| service.ports | list | `[]` |  |
| service.targetPort | string | `"http"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.labels | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.path | string | `"/metrics"` |  |
| serviceMonitor.port | string | `"http"` |  |
| sidecars | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |
