# generic

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A highly flexible and unopinionated Helm chart for deploying Kubernetes workloads.
Supports Deployments, CronJobs, and Jobs with extensive configuration options.
Designed for maximum flexibility while maintaining security best practices by default.
Optimized for AWS with ALB ingress controller support.

## Features

- **Multiple Workload Types**: Supports deployments, cronjobs, and jobs
- **Flexible Networking**: Service, Ingress (ALB), and Gateway API support
- **Advanced Scaling**: HPA and VPA autoscaling options
- **Security**: RBAC, NetworkPolicy, Pod Security Standards, and secure defaults
- **Persistence**: Multiple volume types, CSI snapshots, and volume claim templates
- **Cloud Native**: External Secrets
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

# Deploy with custom image
helm install my-release dnd-it/generic \
  --set deployment.enabled=true \
  --set image.repository=myorg/myapp \
  --set image.tag=v1.0.0

# Deploy a CronJob
helm install my-release dnd-it/generic \
  --set deployment.enabled=false \
  --set cronjobs.backup.enabled=true \
  --set cronjobs.backup.schedule="0 * * * *" \
  --set cronjobs.backup.image.repository=myorg/backup-job
```

## Examples

### Basic Web Application

```yaml
image:
  repository: nginx
  tag: "1.21-alpine"

service:
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: alb
  alb:
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
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

### Application with ALB Ingress

```yaml
deployment:
  enabled: true
  replicas: 2

image:
  repository: myorg/webapp
  tag: "v2.0.0"

ingress:
  enabled: true
  className: alb
  alb:
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:123456789012:certificate/12345678
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      alb.ingress.kubernetes.io/group.name: shared-alb
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
```

### CronJob Example

```yaml
deployment:
  enabled: false  # Disable main deployment

cronjobs:
  backup:
    enabled: true
    schedule: "0 2 * * *"  # Daily at 2 AM
    concurrencyPolicy: Forbid
    successfulJobsHistoryLimit: 3
    failedJobsHistoryLimit: 1
    image:
      repository: myorg/backup-tool
      tag: "v1.0.0"
    command: ["/bin/sh"]
    args: ["-c", "backup-script.sh"]
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
    env:
      - name: BACKUP_BUCKET
        value: "s3://my-backups"

  cleanup:
    enabled: true
    schedule: "0 */6 * * *"  # Every 6 hours
    image:
      repository: myorg/cleanup-tool
      tag: "latest"
    command: ["python", "cleanup.py"]
```

### Job Example

```yaml
deployment:
  enabled: false  # Disable main deployment

jobs:
  migration:
    enabled: true
    backoffLimit: 3
    completions: 1
    parallelism: 1
    ttlSecondsAfterFinished: 300
    image:
      repository: myorg/migration-tool
      tag: "v2.0.0"
    command: ["python", "migrate.py"]
    env:
      - name: DATABASE_URL
        value: "postgresql://localhost/myapp"
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
```

### Multiple Deployments Example

```yaml
# Main deployment
deployment:
  enabled: true
  replicas: 3
  env:
    - name: SERVICE_TYPE
      value: "api"

image:
  repository: myorg/api
  tag: "v1.0.0"

# Additional deployments
extraDeployments:
  worker:
    replicas: 2
    image:
      repository: myorg/worker
      tag: "v1.0.0"
    env:
      - name: SERVICE_TYPE
        value: "worker"
    resources:
      requests:
        cpu: 200m
        memory: 512Mi

  admin:
    replicas: 1
    image:
      repository: myorg/admin
      tag: "v1.0.0"
    env:
      - name: SERVICE_TYPE
        value: "admin"
    ports:
      - name: http
        containerPort: 8080
```

## Upgrading

### Breaking Changes in v0.0.2

1. **Workload Structure Changed**:
   - Removed `workload.type` configuration
   - StatefulSet and DaemonSet no longer supported
   - Use `deployment.enabled`, `cronjobs`, and `jobs` instead

2. **Monitoring Resources Removed**:
   - ServiceMonitor, PodMonitor, PrometheusRule removed
   - Datadog custom resources moved to separate `datadog-resources` chart

3. **Ingress Controller**:
   - Removed `ingress.controller` field
   - Only ALB ingress controller is supported
   - Removed `ingress.nginx` configuration section

### Migration Guide

```yaml
# Old structure
workload:
  type: deployment
  enabled: true
  replicas: 3

# New structure
deployment:
  enabled: true
  replicas: 3

# Old CronJob
workload:
  type: cronjob
  schedule: "0 * * * *"

# New CronJob
deployment:
  enabled: false
cronjobs:
  mycron:
    enabled: true
    schedule: "0 * * * *"
```

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
| affinity | object | `{}` |  |
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
| cronjobs | object | `{}` |  |
| deployment.args | list | `[]` |  |
| deployment.command | list | `[]` |  |
| deployment.enabled | bool | `true` |  |
| deployment.env | list | `[]` |  |
| deployment.envFrom | list | `[]` |  |
| deployment.lifecycle | object | `{}` |  |
| deployment.livenessProbe | object | `{}` |  |
| deployment.progressDeadlineSeconds | int | `600` |  |
| deployment.readinessProbe | object | `{}` |  |
| deployment.replicas | int | `1` |  |
| deployment.resources.limits.memory | string | `"256Mi"` |  |
| deployment.resources.requests.cpu | string | `"100m"` |  |
| deployment.resources.requests.memory | string | `"128Mi"` |  |
| deployment.revisionHistoryLimit | int | `2` |  |
| deployment.securityContext | object | `{}` |  |
| deployment.startupProbe | object | `{}` |  |
| deployment.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| deployment.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| deployment.strategy.type | string | `"RollingUpdate"` |  |
| deployment.volumeMounts | list | `[]` |  |
| dnsConfig | object | `{}` |  |
| dnsPolicy | string | `""` |  |
| emptyDirVolumes | object | `{}` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| externalSecrets | object | `{}` |  |
| extraConfigMaps | object | `{}` |  |
| extraDeployments | object | `{}` |  |
| extraIngresses | object | `{}` |  |
| extraObjects | list | `[]` |  |
| extraSecrets | object | `{}` |  |
| extraServices | object | `{}` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
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
| generic.branchName | string | `""` |  |
| generic.environment | string | `""` |  |
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
| hpa.behavior | object | `{}` |  |
| hpa.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.metrics[0].resource.name | string | `"cpu"` |  |
| hpa.metrics[0].resource.target.averageUtilization | int | `80` |  |
| hpa.metrics[0].resource.target.type | string | `"Utilization"` |  |
| hpa.metrics[0].type | string | `"Resource"` |  |
| hpa.metrics[1].resource.name | string | `"memory"` |  |
| hpa.metrics[1].resource.target.averageUtilization | int | `80` |  |
| hpa.metrics[1].resource.target.type | string | `"Utilization"` |  |
| hpa.metrics[1].type | string | `"Resource"` |  |
| hpa.minReplicas | int | `1` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.k8s.io/pause"` |  |
| image.tag | string | `"3.10"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"alb"` |  |
| ingress.defaultBackend | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts | list | `[]` |  |
| ingress.labels | object | `{}` |  |
| initContainers | list | `[]` |  |
| jobs | object | `{}` |  |
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
| persistence.volumeMode | string | `"Filesystem"` |  |
| persistence.volumes | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podDisruptionBudget.unhealthyPodEvictionPolicy | string | `""` |  |
| podLabels | object | `{}` |  |
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
| rbac.aggregationRule | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.enabled | bool | `false` |  |
| rbac.extraRoles | object | `{}` |  |
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
| sidecarContainers | list | `[]` |  |
| terminationGracePeriodSeconds | int | `30` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints[0].maxSkew | int | `1` |  |
| topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| topologySpreadConstraints[1].maxSkew | int | `1` |  |
| topologySpreadConstraints[1].topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| topologySpreadConstraints[1].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| vpa.annotations | object | `{}` |  |
| vpa.containerPolicies | list | `[]` |  |
| vpa.enabled | bool | `false` |  |
| vpa.labels | object | `{}` |  |
| vpa.recommenders | list | `[]` |  |
| vpa.resourcePolicy | object | `{}` |  |
| vpa.updateMode | string | `"Auto"` |  |
| vpa.updatePolicy | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v0.0.2](https://github.com/norwoodj/helm-docs/releases/v0.0.2)
