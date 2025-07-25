# generic

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A highly flexible and unopinionated Helm chart for deploying any Kubernetes workload.
Supports Deployments, StatefulSets, DaemonSets, Jobs, and CronJobs with extensive
configuration options. Designed for maximum flexibility while maintaining security
best practices by default. Optimized for AWS with ALB ingress controller as default.

## Features

- **All Workload Types**: Supports Deployment, StatefulSet, DaemonSet, Job, and CronJob
- **Flexible Networking**: Service, Ingress (ALB/NGINX), and Gateway API support
- **Advanced Scaling**: HPA, VPA, and KEDA autoscaling options
- **Comprehensive Security**: RBAC, NetworkPolicy, Pod Security Standards, and secure defaults
- **Persistence**: Multiple volume types, CSI snapshots, and StatefulSet volume claims
- **Observability**: Prometheus, Datadog, and custom metrics integration
- **Cloud Native**: External Secrets, workload identity, and native sidecar containers
- **High Availability**: PDB, topology spread, and anti-affinity configurations
- **Extensibility**: Helm hooks, extra objects, and modular template architecture

## Quick Start

### Add the Helm Repository

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update
```

### Install the Chart

```bash
# Basic installation
helm install my-release dnd-it/generic

# With custom values
helm install my-release dnd-it/generic -f values.yaml

# Deploy as StatefulSet
helm install my-release dnd-it/generic \
  --set workload.type=statefulset \
  --set image.repository=postgres \
  --set image.tag=15-alpine

# Deploy as CronJob
helm install my-release dnd-it/generic \
  --set workload.type=cronjob \
  --set workload.schedule="0 * * * *" \
  --set image.repository=myorg/backup-job
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

- Documentation: [Chart Documentation](https://github.com/dnd-it/helm-charts/tree/main/charts/generic)
- Issues: [GitHub Issues](https://github.com/dnd-it/helm-charts/issues)
- Discussions: [GitHub Discussions](https://github.com/dnd-it/helm-charts/discussions)

**Homepage:** <https://github.com/dnd-it/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <abc@abc.com> |  |

## Source Code

* <https://github.com/dnd-it/helm-charts>

## Requirements

Kubernetes: `>=1.29.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| activeDeadlineSeconds | string | `nil` |  |
| additionalIngresses | object | `{}` |  |
| additionalServices | object | `{}` |  |
| affinity | object | `{}` |  |
| autoscaling.behavior | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.metrics[0].resource.name | string | `"cpu"` |  |
| autoscaling.metrics[0].resource.target.averageUtilization | int | `80` |  |
| autoscaling.metrics[0].resource.target.type | string | `"Utilization"` |  |
| autoscaling.metrics[0].type | string | `"Resource"` |  |
| autoscaling.metrics[1].resource.name | string | `"memory"` |  |
| autoscaling.metrics[1].resource.target.averageUtilization | int | `80` |  |
| autoscaling.metrics[1].resource.target.type | string | `"Utilization"` |  |
| autoscaling.metrics[1].type | string | `"Resource"` |  |
| autoscaling.minReplicas | int | `1` |  |
| commonEnvVars | bool | `false` |  |
| configMap.annotations | object | `{}` |  |
| configMap.binaryData | object | `{}` |  |
| configMap.data | object | `{}` |  |
| configMap.enabled | bool | `false` |  |
| configMap.envFrom | bool | `false` |  |
| configMap.labels | object | `{}` |  |
| configMap.mountPath | string | `""` |  |
| configMap.subPath | string | `""` |  |
| containerPorts | list | `[]` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| containerSecurityContext.runAsNonRoot | bool | `true` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| containers | list | `[]` |  |
| datadogDashboard.dashboards | object | `{}` |  |
| datadogDashboard.enabled | bool | `false` |  |
| datadogMetric.enabled | bool | `false` |  |
| datadogMetric.metrics | object | `{}` |  |
| datadogMonitor.enabled | bool | `false` |  |
| datadogMonitor.monitors | object | `{}` |  |
| datadogSLO.enabled | bool | `false` |  |
| datadogSLO.slos | object | `{}` |  |
| deployment.args | list | `[]` |  |
| deployment.command | list | `[]` |  |
| deployment.env | list | `[]` |  |
| deployment.envFrom | list | `[]` |  |
| deployment.lifecycle | object | `{}` |  |
| deployment.livenessProbe | object | `{}` |  |
| deployment.readinessProbe | object | `{}` |  |
| deployment.resources.limits.memory | string | `"256Mi"` |  |
| deployment.resources.requests.cpu | string | `"100m"` |  |
| deployment.resources.requests.memory | string | `"128Mi"` |  |
| deployment.securityContext | object | `{}` |  |
| deployment.startupProbe | object | `{}` |  |
| deployment.volumeMounts | list | `[]` |  |
| dnsConfig | object | `{}` |  |
| dnsPolicy | string | `""` |  |
| emptyDirVolumes | object | `{}` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| externalSecrets | object | `{}` |  |
| extraConfigMaps | object | `{}` |  |
| extraObjects | list | `[]` |  |
| extraSecrets | object | `{}` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| gateway.gateway.additionalGateways | object | `{}` |  |
| gateway.gateway.addresses | list | `[]` |  |
| gateway.gateway.annotations | object | `{}` |  |
| gateway.gateway.enabled | bool | `false` |  |
| gateway.gateway.gatewayClassName | string | `""` |  |
| gateway.gateway.labels | object | `{}` |  |
| gateway.gateway.listeners | list | `[]` |  |
| gateway.gateway.name | string | `""` |  |
| gateway.gateway.tls.certificateRefs | list | `[]` |  |
| gateway.gateway.tls.enabled | bool | `false` |  |
| gateway.gateway.tls.mode | string | `"Terminate"` |  |
| gateway.gatewayClass.additionalClasses | object | `{}` |  |
| gateway.gatewayClass.annotations | object | `{}` |  |
| gateway.gatewayClass.controllerName | string | `"example.com/gateway-controller"` |  |
| gateway.gatewayClass.description | string | `"Gateway class for generic application"` |  |
| gateway.gatewayClass.enabled | bool | `false` |  |
| gateway.gatewayClass.labels | object | `{}` |  |
| gateway.gatewayClass.name | string | `""` |  |
| gateway.gatewayClass.parametersRef | object | `{}` |  |
| gateway.httpRoute.additionalRoutes | object | `{}` |  |
| gateway.httpRoute.annotations | object | `{}` |  |
| gateway.httpRoute.enabled | bool | `false` |  |
| gateway.httpRoute.gatewayName | string | `""` |  |
| gateway.httpRoute.gatewayNamespace | string | `""` |  |
| gateway.httpRoute.hostnames | list | `[]` |  |
| gateway.httpRoute.labels | object | `{}` |  |
| gateway.httpRoute.parentRefs | list | `[]` |  |
| gateway.httpRoute.rules | list | `[]` |  |
| gateway.referenceGrant.additionalGrants | object | `{}` |  |
| gateway.referenceGrant.annotations | object | `{}` |  |
| gateway.referenceGrant.enabled | bool | `false` |  |
| gateway.referenceGrant.from | list | `[]` |  |
| gateway.referenceGrant.labels | object | `{}` |  |
| gateway.referenceGrant.to | list | `[]` |  |
| gateway.tcpRoute.additionalRoutes | object | `{}` |  |
| gateway.tcpRoute.annotations | object | `{}` |  |
| gateway.tcpRoute.enabled | bool | `false` |  |
| gateway.tcpRoute.gatewayName | string | `""` |  |
| gateway.tcpRoute.gatewayNamespace | string | `""` |  |
| gateway.tcpRoute.labels | object | `{}` |  |
| gateway.tcpRoute.parentRefs | list | `[]` |  |
| gateway.tcpRoute.rules | list | `[]` |  |
| generic.branchName | string | `""` |  |
| generic.environment | string | `""` |  |
| generic.feature | bool | `true` |  |
| generic.name | string | `""` |  |
| generic.version | string | `""` |  |
| global.annotations | object | `{}` |  |
| global.labels | object | `{}` |  |
| hooks.enabled | bool | `false` |  |
| hooks.postDelete | list | `[]` |  |
| hooks.postInstall | list | `[]` |  |
| hooks.postUpgrade | list | `[]` |  |
| hooks.preDelete | list | `[]` |  |
| hooks.preInstall | list | `[]` |  |
| hooks.preUpgrade | list | `[]` |  |
| hostAliases | list | `[]` |  |
| hostIPC | bool | `false` |  |
| hostNetwork | bool | `false` |  |
| hostPID | bool | `false` |  |
| hostPathVolumes | object | `{}` |  |
| hostname | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"nginx"` |  |
| image.tag | string | `"1.21-alpine"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.alb.annotations | object | `{}` |  |
| ingress.annotations | object | `{}` |  |
| ingress.certManager.annotations | object | `{}` |  |
| ingress.certManager.clusterIssuer | string | `""` |  |
| ingress.certManager.enabled | bool | `false` |  |
| ingress.certManager.issuer | string | `""` |  |
| ingress.className | string | `""` |  |
| ingress.controller | string | `""` |  |
| ingress.defaultBackend | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts | list | `[]` |  |
| ingress.labels | object | `{}` |  |
| ingress.nginx.annotations | object | `{}` |  |
| ingress.tls | list | `[]` |  |
| initContainers | list | `[]` |  |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| networkPolicy.egress | list | `[]` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress | list | `[]` |  |
| networkPolicy.policyTypes[0] | string | `"Ingress"` |  |
| networkPolicy.policyTypes[1] | string | `"Egress"` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.dataSource | object | `{}` |  |
| persistence.enabled | bool | `false` |  |
| persistence.labels | object | `{}` |  |
| persistence.mountPath | string | `"/data"` |  |
| persistence.selector | object | `{}` |  |
| persistence.size | string | `"8Gi"` |  |
| persistence.storageClass | string | `""` |  |
| persistence.subPath | string | `""` |  |
| persistence.volumeClaimTemplate | bool | `false` |  |
| persistence.volumeMode | string | `"Filesystem"` |  |
| persistence.volumes | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podDisruptionBudget.unhealthyPodEvictionPolicy | string | `""` |  |
| podLabels | object | `{}` |  |
| podMonitor.additionalMonitors | object | `{}` |  |
| podMonitor.annotations | object | `{}` |  |
| podMonitor.enabled | bool | `false` |  |
| podMonitor.endpoints | list | `[]` |  |
| podMonitor.interval | string | `"30s"` |  |
| podMonitor.jobLabel | string | `""` |  |
| podMonitor.labelLimit | int | `0` |  |
| podMonitor.labelNameLengthLimit | int | `0` |  |
| podMonitor.labelValueLengthLimit | int | `0` |  |
| podMonitor.labels | object | `{}` |  |
| podMonitor.metricRelabelings | list | `[]` |  |
| podMonitor.namespaceSelector | object | `{}` |  |
| podMonitor.path | string | `"/metrics"` |  |
| podMonitor.podTargetLabels | list | `[]` |  |
| podMonitor.port | string | `"http"` |  |
| podMonitor.relabelings | list | `[]` |  |
| podMonitor.sampleLimit | int | `0` |  |
| podMonitor.scheme | string | `"http"` |  |
| podMonitor.scrapeTimeout | string | `"10s"` |  |
| podMonitor.selector | object | `{}` |  |
| podMonitor.targetLabels | list | `[]` |  |
| podMonitor.targetLimit | int | `0` |  |
| podMonitor.tlsConfig | object | `{}` |  |
| podSecurity.podSecurityStandards.annotations | object | `{}` |  |
| podSecurity.podSecurityStandards.audit | string | `""` |  |
| podSecurity.podSecurityStandards.enabled | bool | `false` |  |
| podSecurity.podSecurityStandards.enforce | string | `""` |  |
| podSecurity.podSecurityStandards.labels | object | `{}` |  |
| podSecurity.podSecurityStandards.namespaceEnforcement | bool | `false` |  |
| podSecurity.podSecurityStandards.warn | string | `""` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| podSecurityContext.runAsGroup | int | `1000` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| priority | string | `nil` |  |
| priorityClassName | string | `""` |  |
| prometheusRule.additionalRules | object | `{}` |  |
| prometheusRule.annotations | object | `{}` |  |
| prometheusRule.enabled | bool | `false` |  |
| prometheusRule.groups | list | `[]` |  |
| prometheusRule.labels | object | `{}` |  |
| rbac.additionalRoles | object | `{}` |  |
| rbac.aggregationRule | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.enabled | bool | `false` |  |
| rbac.labels | object | `{}` |  |
| rbac.roleRef | string | `""` |  |
| rbac.rules | list | `[]` |  |
| rbac.subjects | list | `[]` |  |
| rbac.type | string | `"Role"` |  |
| restartPolicy | string | `nil` |  |
| runtimeClassName | string | `""` |  |
| schedulerName | string | `""` |  |
| secret.annotations | object | `{}` |  |
| secret.data | object | `{}` |  |
| secret.enabled | bool | `false` |  |
| secret.envFrom | bool | `false` |  |
| secret.labels | object | `{}` |  |
| secret.mountPath | string | `""` |  |
| secret.stringData | object | `{}` |  |
| secret.subPath | string | `""` |  |
| secret.type | string | `"Opaque"` |  |
| security.apparmor.enabled | bool | `false` |  |
| security.apparmor.profile | string | `"runtime/default"` |  |
| security.podSecurityStandards.audit | string | `""` |  |
| security.podSecurityStandards.enforce | string | `""` |  |
| security.podSecurityStandards.warn | string | `""` |  |
| security.seccomp.annotations | bool | `false` |  |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `""` |  |
| service.enabled | bool | `true` |  |
| service.externalTrafficPolicy | string | `nil` |  |
| service.labels | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.ports[0].name | string | `"http"` |  |
| service.ports[0].port | int | `80` |  |
| service.ports[0].protocol | string | `"TCP"` |  |
| service.ports[0].targetPort | int | `80` |  |
| service.publishNotReadyAddresses | bool | `false` |  |
| service.sessionAffinity | string | `nil` |  |
| service.sessionAffinityConfig | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.labels | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.metricRelabelings | list | `[]` |  |
| serviceMonitor.path | string | `"/metrics"` |  |
| serviceMonitor.port | string | `"http"` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.scheme | string | `"http"` |  |
| serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| serviceMonitor.tlsConfig | object | `{}` |  |
| sidecarContainers | list | `[]` |  |
| sidecars | list | `[]` |  |
| terminationGracePeriodSeconds | int | `30` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| vpa.annotations | object | `{}` |  |
| vpa.containerPolicies | list | `[]` |  |
| vpa.enabled | bool | `false` |  |
| vpa.labels | object | `{}` |  |
| vpa.recommenders | list | `[]` |  |
| vpa.resourcePolicy | object | `{}` |  |
| vpa.updateMode | string | `"Auto"` |  |
| vpa.updatePolicy | object | `{}` |  |
| workload.backoffLimit | int | `6` |  |
| workload.completions | int | `1` |  |
| workload.concurrencyPolicy | string | `"Allow"` |  |
| workload.enabled | bool | `true` |  |
| workload.failedJobsHistoryLimit | int | `1` |  |
| workload.parallelism | int | `1` |  |
| workload.podManagementPolicy | string | `"OrderedReady"` |  |
| workload.progressDeadlineSeconds | int | `600` |  |
| workload.replicas | int | `1` |  |
| workload.restartPolicy | string | `"OnFailure"` |  |
| workload.revisionHistoryLimit | int | `2` |  |
| workload.schedule | string | `"0 * * * *"` |  |
| workload.serviceName | string | `""` |  |
| workload.startingDeadlineSeconds | int | `200` |  |
| workload.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| workload.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| workload.strategy.type | string | `"RollingUpdate"` |  |
| workload.successfulJobsHistoryLimit | int | `3` |  |
| workload.ttlSecondsAfterFinished | int | `300` |  |
| workload.type | string | `"deployment"` |  |
| workload.updateStrategy.type | string | `"RollingUpdate"` |  |
| workload.volumeClaimTemplates | object | `{}` |  |
| workloadAnnotations | object | `{}` |  |
| workloadLabels | object | `{}` |  |
