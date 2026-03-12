# Charts Overview

All application charts are thin wrappers around a shared [common library](../architecture/common-library.md). They provide opinionated defaults for specific workload types while inheriting secure defaults, Datadog integration, and consistent templating.

## Application Charts

### Workload Charts

| Chart | Type | Description |
|-------|------|-------------|
| [**generic**](generic.md) | Deployment / StatefulSet / DaemonSet / Job / CronJob | Full-featured, unopinionated chart for any workload |
| [**web**](web.md) | Deployment | External-facing HTTP applications with Gateway API |
| [**api**](api.md) | Deployment | Internal API services with ClusterIP |
| [**worker**](worker.md) | Deployment | Background processing without networking |
| [**task**](task.md) | CronJob | Scheduled jobs |

### Infrastructure Charts

| Chart | Description |
|-------|-------------|
| [**karpenter-resources**](karpenter-resources.md) | Karpenter NodePool and EC2NodeClass resources |
| [**datadog-resources**](datadog-resources.md) | Datadog monitors, dashboards, and SLOs |
| [**custom-resources**](custom-resources.md) | Deploy arbitrary Kubernetes custom resources |

## Chart Comparison

What each wrapper chart enables by default:

| Feature | web | api | worker | task |
|---------|-----|-----|--------|------|
| Workload type | Deployment | Deployment | Deployment | CronJob |
| Service | :material-check: ClusterIP | :material-check: ClusterIP | :material-close: | :material-close: |
| HTTPRoute | :material-check: | :material-close: | :material-close: | :material-close: |
| Target Group Config | :material-check: | :material-close: | :material-close: | :material-close: |
| Load Balancer Config | :material-check: internet-facing | :material-close: | :material-close: | :material-close: |
| Health probes | /livez, /readyz, startup | /livez, /readyz, startup | none | none |
| Default port | 8080 | 8080 | none | none |
| HPA min replicas | 2 | 2 | 1 | n/a |
| Topology spread | :material-check: | :material-check: | :material-check: | :material-close: |
| Node selector | amd64 | amd64 | none | none |

## Deprecated Charts

!!! warning "Deprecated"
    The following charts are deprecated. Migrate to their replacements.

| Deprecated | Replacement |
|------------|-------------|
| `webapp` | [web](web.md) |
| `cronjob` | [task](task.md) |

See the [migration guide](../guides/migration.md) for instructions.
