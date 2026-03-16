# Task Chart

Opinionated chart for **scheduled CronJob workloads**. Pre-configured with sensible job defaults and no networking.

## What's Pre-configured

| Setting | Default |
|---------|---------|
| Workload type | CronJob |
| Deployment | Disabled |
| Service | Disabled |
| Schedule | `0 * * * *` (hourly, override required) |
| Concurrency policy | Forbid |
| History | 3 successful, 1 failed |
| Restart policy | OnFailure |
| Job backoff limit | 6 |
| TTL after finished | 300s (5 minutes) |
| Resources | 100m CPU, 128Mi memory (pod-level) |

## Minimal Example

```yaml
image:
  repository: my-registry/my-task
  tag: "1.0.0"

schedule: "0 2 * * *"  # Daily at 2am

command: ["python"]
args: ["-m", "cleanup"]
```

## Full Example

```yaml
image:
  repository: my-registry/my-task
  tag: "1.0.0"

schedule: "*/15 * * * *"  # Every 15 minutes

command: ["python"]
args: ["-m", "sync", "--full"]

concurrencyPolicy: Replace
successfulJobsHistoryLimit: 5
failedJobsHistoryLimit: 3

job:
  backoffLimit: 3
  ttlSecondsAfterFinished: 600
  activeDeadlineSeconds: 1800  # Timeout after 30 minutes

resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    memory: 1Gi

env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: url

serviceAccount:
  enabled: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789:role/MyTaskRole"
```

## Concurrency Policies

| Policy | Behavior |
|--------|----------|
| `Forbid` | Skip new run if previous is still running (default) |
| `Replace` | Cancel running job and start new one |
| `Allow` | Run concurrently with existing jobs |
