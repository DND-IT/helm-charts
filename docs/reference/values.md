# Values Reference

Complete reference for all configuration values available in the common library. All wrapper charts (web, api, worker, task) and the generic chart inherit these values.

## Global

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `global.image.registry` | string | `""` | Container registry prepended to all images |
| `commonLabels` | object | `{}` | Labels applied to all resources |
| `commonAnnotations` | object | `{}` | Annotations applied to all resources |
| `nameOverride` | string | `""` | Override the chart name |
| `fullnameOverride` | string | `""` | Override the full resource name |
| `namespaceOverride` | string | `""` | Override the release namespace |

## Image

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `image.registry` | string | `""` | Container registry |
| `image.repository` | string | `""` | **Required.** Image repository |
| `image.tag` | string | `""` | **Required.** Image tag |
| `image.pullPolicy` | string | `IfNotPresent` | Image pull policy |
| `imagePullSecrets` | list | `[]` | Image pull secrets |

## Deployment

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `deploymentEnabled` | bool | `true` | Create a Deployment |
| `replicas` | int | `1` | Number of replicas |
| `revisionHistoryLimit` | int | `2` | Number of old ReplicaSets to retain |
| `strategy.type` | string | `RollingUpdate` | Deployment strategy |
| `strategy.rollingUpdate.maxUnavailable` | string/int | `25%` | Max unavailable during rollout |
| `strategy.rollingUpdate.maxSurge` | string/int | `25%` | Max surge during rollout |
| `progressDeadlineSeconds` | int | `600` | Deployment progress deadline |

## Container

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `command` | list | `[]` | Container command |
| `args` | list | `[]` | Container arguments |
| `ports` | list | `[]` | Container ports |
| `resources` | object | `{}` | **Pod-level** resource requests/limits |
| `container.resources` | object | `{}` | **Container-level** resource requests/limits |
| `securityContext` | object | `{}` | Container security context override |
| `lifecycle` | object | `{}` | Container lifecycle hooks |

## Probes

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `livenessProbe` | object | `{}` | Liveness probe configuration |
| `readinessProbe` | object | `{}` | Readiness probe configuration |
| `startupProbe` | object | `{}` | Startup probe configuration |

## Environment

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `env` | list | `[]` | Environment variables |
| `envFrom` | list | `[]` | Environment from ConfigMap/Secret |
| `extraEnvFrom` | list | `[]` | Additional envFrom sources |
| `commonEnvVars` | bool | `true` | Inject [common env vars](common-env-vars.md) |

## Additional Containers

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `initContainers` | list | `[]` | Init containers |
| `sidecarContainers` | list | `[]` | Native sidecar containers (restartPolicy: Always) |
| `extraContainers` | list | `[]` | Additional containers |

## Pod

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `pod.labels` | object | `{}` | Additional pod labels |
| `pod.annotations` | object | `{}` | Additional pod annotations |
| `pod.securityContext` | object | `{}` | Pod security context override |
| `pod.restartPolicy` | string | `""` | Pod restart policy |
| `pod.terminationGracePeriodSeconds` | int | `30` | Grace period for shutdown |
| `pod.dnsPolicy` | string | `""` | DNS policy |
| `pod.dnsConfig` | object | `{}` | DNS configuration |
| `pod.priorityClassName` | string | `""` | Priority class |
| `pod.hostNetwork` | bool | `false` | Use host networking |

## Scheduling

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `scheduling.nodeSelector` | object | `{}` | Node selector |
| `scheduling.tolerations` | list | `[]` | Tolerations |
| `scheduling.affinity` | object | `{}` | Affinity rules |
| `scheduling.topologySpreadConstraints` | list | `[]` | Topology spread constraints |

## Volumes

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `volumes.persistent` | object | `{}` | PersistentVolumeClaim volumes |
| `volumes.emptyDir` | object | `{}` | EmptyDir volumes |
| `volumes.hostPath` | object | `{}` | HostPath volumes |
| `volumes.extra` | list | `[]` | Additional volume definitions |
| `volumes.extraMounts` | list | `[]` | Additional volume mounts |

## Service

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `service.enabled` | bool | `false` | Create a Service |
| `service.type` | string | `ClusterIP` | Service type |
| `service.ports` | list | `[]` | Service ports |
| `service.annotations` | object | `{}` | Service annotations |
| `extraServices` | object | `{}` | Additional Services |

## Gateway API

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `gateway.httpRoute.enabled` | bool | `false` | Create HTTPRoute |
| `gateway.httpRoute.parentRefs` | list | `[]` | Gateway references |
| `gateway.httpRoute.hostnames` | list | `[]` | Hostnames to match |
| `gateway.httpRoute.rules` | list | `[]` | Routing rules |
| `gateway.grpcRoute.enabled` | bool | `false` | Create GRPCRoute |
| `gateway.tcpRoute.enabled` | bool | `false` | Create TCPRoute |
| `gateway.tlsRoute.enabled` | bool | `false` | Create TLSRoute |
| `gateway.udpRoute.enabled` | bool | `false` | Create UDPRoute |
| `gateway.targetGroupConfiguration.enabled` | bool | `false` | Create TargetGroupConfiguration |
| `gateway.loadBalancerConfiguration.enabled` | bool | `false` | Create LoadBalancerConfiguration |
| `gateway.loadBalancerConfiguration.scheme` | string | `""` | `internet-facing` or `internal` |
| `gateway.referenceGrant.enabled` | bool | `false` | Create ReferenceGrant |

## Autoscaling

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `hpa.enabled` | bool | `false` | Create HorizontalPodAutoscaler |
| `hpa.minReplicas` | int | `1` | Minimum replicas |
| `hpa.maxReplicas` | int | `10` | Maximum replicas |
| `hpa.metrics` | list | `[]` | Scaling metrics |
| `hpa.behavior` | object | `{}` | Scaling behavior |
| `vpa.enabled` | bool | `false` | Create VerticalPodAutoscaler |
| `podDisruptionBudget.enabled` | bool | `false` | Create PodDisruptionBudget |
| `podDisruptionBudget.minAvailable` | int | `1` | Minimum available pods |

## Config and Secrets

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `configMap.enabled` | bool | `false` | Create ConfigMap |
| `configMap.data` | object | `{}` | ConfigMap data |
| `configMap.envFrom` | bool | `false` | Inject as env vars |
| `configMap.mountPath` | string | `""` | Mount path |
| `secret.enabled` | bool | `false` | Create Secret |
| `secret.stringData` | object | `{}` | Secret string data |
| `secret.envFrom` | bool | `false` | Inject as env vars |
| `externalSecrets` | object | `{}` | External Secrets Operator |
| `extraConfigMaps` | object | `{}` | Additional ConfigMaps |
| `extraSecrets` | object | `{}` | Additional Secrets |

## Security

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `security.defaultPodSecurityContext` | object | See [security guide](../guides/security.md) | Default pod security context |
| `security.defaultContainerSecurityContext` | object | See [security guide](../guides/security.md) | Default container security context |
| `serviceAccount.enabled` | bool | `true` | Create ServiceAccount |
| `serviceAccount.annotations` | object | `{}` | SA annotations (e.g., IRSA) |
| `rbac.enabled` | bool | `false` | Create Role/RoleBinding |
| `rbac.rules` | list | `[]` | RBAC rules |
| `networkPolicy.enabled` | bool | `false` | Create NetworkPolicy |

## Datadog

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `datadog.enabled` | bool | `true` | Enable Datadog unified service tagging |
| `datadog.service` | string | chart fullname | Service name |
| `datadog.env` | string | release namespace | Environment |
| `datadog.version` | string | `image.tag` | Version |

## CronJob (singular)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `schedule` | string | `""` | Cron schedule (triggers CronJob mode) |
| `concurrencyPolicy` | string | `Forbid` | Concurrency policy |
| `successfulJobsHistoryLimit` | int | `3` | Successful job history |
| `failedJobsHistoryLimit` | int | `1` | Failed job history |
| `suspend` | bool | `false` | Suspend the CronJob |
| `job.backoffLimit` | int | `6` | Job backoff limit |
| `job.ttlSecondsAfterFinished` | int | `300` | TTL after completion |

## Extra Resources

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `extraDeployments` | object | `{}` | Additional Deployments |
| `extraServices` | object | `{}` | Additional Services |
| `extraIngresses` | object | `{}` | Additional Ingresses |
| `jobs` | object | `{}` | One-off Jobs |
| `cronjobs` | object | `{}` | Additional CronJobs |
| `hooks.enabled` | bool | `false` | Enable Helm hooks |
| `extraObjects` | list | `[]` | Arbitrary extra resources |
