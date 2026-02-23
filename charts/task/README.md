# task

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying scheduled CronJob workloads to Kubernetes.
Includes CronJob and ServiceAccount.
Designed for scheduled tasks with configurable concurrency, history limits, and job settings.
No HPA, PDB, service, or ingress - focused purely on scheduled job execution.

## Overview

The **task** chart is an opinionated Helm chart for deploying scheduled CronJob workloads. It uses the same schema as the `generic` chart but is specifically designed for periodic tasks and batch jobs.

## Use Cases

- **Scheduled backups** - Database dumps, file backups to S3
- **Data synchronization** - Periodic sync between systems
- **Report generation** - Daily/weekly reports
- **Cleanup jobs** - Log rotation, temp file cleanup, expired data removal
- **Health checks** - Periodic external service validation
- **Batch processing** - Scheduled data imports/exports

## Key Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `schedule` | `0 * * * *` | Hourly (customize as needed) |
| `concurrencyPolicy` | `Forbid` | Prevent overlapping runs |
| `successfulJobsHistoryLimit` | `3` | Keep last 3 successful jobs |
| `failedJobsHistoryLimit` | `1` | Keep last failed job |
| `job.backoffLimit` | `6` | Retry failed jobs 6 times |
| `job.ttlSecondsAfterFinished` | `300` | Cleanup after 5 minutes |
| `pod.restartPolicy` | `OnFailure` | Restart on failure |

## Quick Start

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update

helm install my-backup dnd-it/task \
  --set image.repository=myorg/backup-tool \
  --set image.tag=v1.0.0 \
  --set schedule="0 2 * * *"
```

## Examples

### Daily Database Backup

```yaml
image:
  repository: myorg/pg-backup
  tag: "v1.0.0"

schedule: "0 2 * * *"  # Daily at 2 AM

command: ["pg_dump"]
args: ["-h", "$(DB_HOST)", "-U", "$(DB_USER)", "-d", "$(DB_NAME)"]

env:
  - name: DB_HOST
    value: "postgres.default.svc"
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: username
  - name: PGPASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    memory: 1Gi
```

### Hourly Data Sync

```yaml
image:
  repository: myorg/sync-tool
  tag: "v2.1.0"

schedule: "0 * * * *"  # Every hour

concurrencyPolicy: Replace  # Cancel previous if still running

command: ["python", "sync.py"]

env:
  - name: SOURCE_API
    value: "https://api.external.com"
  - name: DEST_BUCKET
    value: "s3://my-data-lake"
```

### Weekly Report Generation

```yaml
image:
  repository: myorg/report-generator
  tag: "v1.5.0"

schedule: "0 6 * * 1"  # Monday at 6 AM

job:
  backoffLimit: 3
  ttlSecondsAfterFinished: 3600  # Keep for 1 hour

command: ["python", "generate_report.py"]

env:
  - name: REPORT_TYPE
    value: "weekly-summary"
  - name: EMAIL_RECIPIENTS
    value: "team@example.com"

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    memory: 4Gi
```

### Cleanup Job with Timezone

```yaml
image:
  repository: myorg/cleanup
  tag: "v1.0.0"

schedule: "0 3 * * *"  # 3 AM in specified timezone
# Note: timeZone requires Kubernetes 1.27+
# timeZone: "America/New_York"

command: ["/bin/sh"]
args:
  - -c
  - |
    echo "Starting cleanup..."
    find /data -type f -mtime +30 -delete
    echo "Cleanup complete"

volumes:
  persistent:
    data:
      enabled: true
      existingClaim: shared-data-pvc
      mountPath: /data
```

### Job with Init Container

```yaml
image:
  repository: myorg/processor
  tag: "v1.0.0"

schedule: "*/30 * * * *"  # Every 30 minutes

initContainers:
  - name: download-data
    image: amazon/aws-cli:latest
    command: ["aws", "s3", "cp", "s3://bucket/data.csv", "/shared/"]
    volumeMounts:
      - name: shared
        mountPath: /shared

volumes:
  emptyDir:
    shared:
      mountPath: /shared

command: ["python", "process.py", "/shared/data.csv"]
```

## Cron Schedule Reference

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday = 0)
│ │ │ │ │
* * * * *
```

Common schedules:
- `0 * * * *` - Every hour
- `*/15 * * * *` - Every 15 minutes
- `0 2 * * *` - Daily at 2 AM
- `0 0 * * 0` - Weekly on Sunday midnight
- `0 0 1 * *` - Monthly on the 1st

## Comparison with Generic Chart

| Feature | task | generic |
|---------|------|---------|
| Workload Type | **CronJob** | Deployment |
| Schedule | Configured | N/A |
| Concurrency Policy | Forbid | N/A |
| Service | Disabled | Disabled |
| Health Probes | N/A | Empty |

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
| concurrencyPolicy | string | `"Forbid"` |  |
| configMap.annotations | object | `{}` |  |
| configMap.binaryData | object | `{}` |  |
| configMap.data | object | `{}` |  |
| configMap.enabled | bool | `false` |  |
| configMap.envFrom | bool | `false` |  |
| configMap.labels | object | `{}` |  |
| configMap.mountPath | string | `""` |  |
| configMap.subPath | string | `""` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| externalSecrets | object | `{}` |  |
| extraConfigMaps | object | `{}` |  |
| extraEnvFrom | list | `[]` |  |
| extraObjects | list | `[]` |  |
| extraSecrets | object | `{}` |  |
| failedJobsHistoryLimit | int | `1` |  |
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
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"busybox"` |  |
| image.tag | string | `"1.36"` |  |
| imagePullSecrets | list | `[]` |  |
| initContainers | list | `[]` |  |
| job.activeDeadlineSeconds | string | `""` |  |
| job.backoffLimit | int | `6` |  |
| job.completionMode | string | `""` |  |
| job.completions | int | `1` |  |
| job.parallelism | int | `1` |  |
| job.ttlSecondsAfterFinished | int | `300` |  |
| lifecycle | object | `{}` |  |
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
| pod.restartPolicy | string | `"OnFailure"` |  |
| pod.runtimeClassName | string | `""` |  |
| pod.schedulerName | string | `""` |  |
| pod.securityContext | object | `{}` |  |
| pod.terminationGracePeriodSeconds | int | `30` |  |
| rbac.aggregationRule | object | `{}` |  |
| rbac.annotations | object | `{}` |  |
| rbac.enabled | bool | `false` |  |
| rbac.extraRoles | object | `{}` |  |
| rbac.labels | object | `{}` |  |
| rbac.roleRef | string | `""` |  |
| rbac.rules | list | `[]` |  |
| rbac.subjects | list | `[]` |  |
| rbac.type | string | `"Role"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| schedule | string | `"0 * * * *"` |  |
| scheduling.affinity | object | `{}` |  |
| scheduling.nodeSelector | object | `{}` |  |
| scheduling.tolerations | list | `[]` |  |
| scheduling.topologySpreadConstraints | list | `[]` |  |
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
| service.enabled | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.labels | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| startingDeadlineSeconds | string | `""` |  |
| successfulJobsHistoryLimit | int | `3` |  |
| suspend | bool | `false` |  |
| volumes.emptyDir | object | `{}` |  |
| volumes.extra | list | `[]` |  |
| volumes.extraMounts | list | `[]` |  |
| volumes.hostPath | object | `{}` |  |
| volumes.persistent | object | `{}` |  |
| workloadAnnotations | object | `{}` |  |
| workloadLabels | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.0.0](https://github.com/norwoodj/helm-docs/releases/v1.0.0)
