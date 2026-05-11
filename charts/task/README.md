# task

![Version: 1.5.0](https://img.shields.io/badge/Version-1.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying scheduled CronJob workloads to Kubernetes.
Includes CronJob and ServiceAccount.
Designed for scheduled tasks with configurable concurrency, history limits, and job settings.
No HPA, PDB, service, or ingress - focused purely on scheduled job execution.

## Overview

The **task** chart is an opinionated Helm chart for deploying scheduled CronJob workloads. Declare each scheduled task as an entry under `cronjobs:` — one entry renders one CronJob. The single chart release can host multiple cron entries that share the same ServiceAccount, ConfigMap, Secret, and volume defaults.

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
| `concurrencyPolicy` (per entry) | `Forbid` | Prevent overlapping runs |
| `successfulJobsHistoryLimit` (per entry) | `3` | Keep last 3 successful jobs |
| `failedJobsHistoryLimit` (per entry) | `1` | Keep last failed job |
| `backoffLimit` (per entry) | `6` | Retry failed jobs 6 times |
| `ttlSecondsAfterFinished` (per entry) | `300` | Cleanup after 5 minutes |
| `restartPolicy` | `OnFailure` | Restart on failure |
| `resources.requests` (root) | `100m` / `128Mi` | Inherited by every entry that does not override |

## Quick Start

```bash
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update

helm install my-backup dnd-it/task \
  --set image.repository=myorg/backup-tool \
  --set image.tag=v1.0.0 \
  --set cronjobs.backup.enabled=true \
  --set cronjobs.backup.schedule="0 2 * * *"
```

## Examples

### Daily Database Backup

```yaml
image:
  repository: myorg/pg-backup
  tag: "v1.0.0"

cronjobs:
  backup:
    enabled: true
    schedule: "0 2 * * *"  # Daily at 2 AM
    command: ["pg_dump"]
    args: ["-h", "$(DB_HOST)", "-U", "$(DB_USER)", "-d", "$(DB_NAME)"]

extraEnv:
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

cronjobs:
  sync:
    enabled: true
    schedule: "0 * * * *"  # Every hour
    concurrencyPolicy: Replace  # Cancel previous if still running
    command: ["python", "sync.py"]

env:
  SOURCE_API: "https://api.external.com"
  DEST_BUCKET: "s3://my-data-lake"
```

### Weekly Report Generation

```yaml
image:
  repository: myorg/report-generator
  tag: "v1.5.0"

cronjobs:
  report:
    enabled: true
    schedule: "0 6 * * 1"  # Monday at 6 AM
    backoffLimit: 3
    ttlSecondsAfterFinished: 3600  # Keep for 1 hour
    command: ["python", "generate_report.py"]

env:
  REPORT_TYPE: "weekly-summary"
  EMAIL_RECIPIENTS: "team@example.com"

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    memory: 4Gi
```

### Multiple CronJobs in One Release

```yaml
image:
  repository: myorg/maintenance
  tag: "v1.0.0"

cronjobs:
  cleanup:
    enabled: true
    schedule: "0 3 * * *"
    timeZone: "America/New_York"  # IANA TZ; requires Kubernetes 1.27+
    command: ["/bin/sh"]
    args:
      - -c
      - find /data -type f -mtime +30 -delete

  rotate-logs:
    enabled: true
    schedule: "0 0 * * 0"
    command: ["/bin/sh"]
    args: ["-c", "logrotate /etc/logrotate.conf"]

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

cronjobs:
  process:
    enabled: true
    schedule: "*/30 * * * *"  # Every 30 minutes
    command: ["python", "process.py", "/shared/data.csv"]
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
| Declaration | `cronjobs:` map (required) | `replicas` etc. |
| Concurrency Policy | per-entry, default `Forbid` | N/A |
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
| cronjobs | object | `{}` |  |
| image.repository | string | `""` |  |
| image.tag | string | `""` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| scheduling.topologySpreadConstraints | list | `[]` |  |
| service.enabled | bool | `false` |  |
| workload.type | string | `"none"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
