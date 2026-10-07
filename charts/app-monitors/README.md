# app-monitors

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Shared Datadog monitors for an application, rendered as DatadogMonitor resources

## Overview

This chart holds the shared monitors that every application should have
(layer 2). The query of each monitor is fixed in the chart. An application turns
monitors on and tunes thresholds and windows through values. The
[Datadog Operator](https://docs.datadoghq.com/containers/datadog_operator/) turns
each `DatadogMonitor` resource into a monitor in Datadog.

| layer | what | where |
| --- | --- | --- |
| 1. infra | cluster and platform namespaces | `fission-argocd/configs/cluster-tools/apps/datadog-monitoring` |
| 2. shared app | the monitors in this chart | this chart, pulled into each app chart |
| 3. app specific | monitors only one app needs | the app repo, e.g. with `datadog-resources` |

If an application needs a different query shape, write a layer 3 monitor. Do not
add a query override here.

## Monitors

| key | resource suffix | default | scope |
| --- | --- | --- | --- |
| `podRestarts` | `pod-restarts` | on | `scope.kubeNamespace` |
| `oomKilled` | `oom-killed` | on | `scope.kubeNamespace` |
| `replicasNotReady` | `replicas-not-ready` | on | `scope.kubeNamespace` |
| `hpaMaxedOut` | `hpa-maxed-out` | off | `scope.kubeNamespace` |
| `sqsOldestMessageAge` | `sqs-oldest-message-age` | off | `env` + `scope.sqsQueues` |
| `sqsBacklog` | `sqs-backlog` | off | `env` + `scope.sqsQueues` |

Each resource is named `<app>-<env>-<suffix>`.

## Usage

Add the chart as a dependency of the application's umbrella chart, off by default:

```yaml
# deploy/app/Chart.yaml
dependencies:
  - name: app-monitors
    repository: https://dnd-it.github.io/helm-charts
    version: 0.1.0
    condition: app-monitors.enabled
```

```yaml
# deploy/app/values.yaml
app-monitors:
  enabled: false
  team: discovery
  app: ai-tools
  extraTags:
    - "github-repo:discovery-ai-tools"
```

Turn it on per environment and set only what differs:

```yaml
# deploy/app/envs/prod/values.yaml
app-monitors:
  enabled: true
  env: prod-discovery
  scope:
    kubeNamespace: discovery-prod-ai-tools
    sqsQueues:
      - celery-broker-backend-ai-tools
  monitors:
    sqsBacklog:
      enabled: true
      critical: 100
      warning: 60
```

Monitors have only a `critical` threshold by default. Add `warning` to get one.

PR preview environments do not set `enabled`, so they create no monitors.

## Routing

Messages contain no `@` handles. Every monitor carries these tags, and Datadog
notification rules route on them:

- `team:<team>`
- `env:<env>`
- `service:<app>`
- `managed-by:app-monitors`
- each entry of `extraTags`

The render fails when `team`, `app` or `env` is missing, or when an enabled
monitor's scope is empty.

## Adding a monitor

1. Check the metric and its tags in the Datadog metrics explorer.
2. Add a block under `monitors:` in `values.yaml` with `enabled`, `window`,
   `critical` and `priority`. Do not set a default `warning`.
3. Add an `include "app-monitors.monitor"` call to the template file for its
   signal family (`workload.yaml`, `hpa.yaml`, `sqs.yaml`), or a new file for a
   new family. Build the query with `printf` from the values, and pass the same
   value as `critical`.
4. Add the key to the table above and a test under `tests/`.
5. New monitors default to `enabled: false` so a chart upgrade does not create
   monitors in every app at once.

## Prerequisites

- Datadog Operator with `datadogMonitor.enabled` on the cluster the app syncs to

**Homepage:** <https://github.com/DND-IT/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <dai@tamedia.ch> |  |

## Source Code

* <https://github.com/DND-IT/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| app | string | `""` | Application name. Used in resource names, the monitor title and the `service:` tag. Required. |
| env | string | `""` | Datadog environment, e.g. `prod-discovery`. Used in resource names, the monitor title and the `env:` tag. Required. |
| extraTags | list | `[]` | Extra tags added to every monitor, e.g. `github-repo:<repo>`. |
| monitors.hpaMaxedOut.enabled | bool | `false` | Enable the HPA at max replicas monitor |
| monitors.hpaMaxedOut.priority | int | `3` |  |
| monitors.hpaMaxedOut.window | string | `"last_30m"` |  |
| monitors.oomKilled.critical | int | `1` |  |
| monitors.oomKilled.enabled | bool | `true` | Enable the OOMKilled monitor |
| monitors.oomKilled.priority | int | `2` |  |
| monitors.oomKilled.window | string | `"last_10m"` |  |
| monitors.podRestarts.critical | int | `3` |  |
| monitors.podRestarts.enabled | bool | `true` | Enable the pod restarts monitor |
| monitors.podRestarts.priority | int | `3` |  |
| monitors.podRestarts.window | string | `"last_15m"` |  |
| monitors.replicasNotReady.critical | int | `1` |  |
| monitors.replicasNotReady.enabled | bool | `true` | Enable the replicas not ready monitor |
| monitors.replicasNotReady.priority | int | `2` |  |
| monitors.replicasNotReady.window | string | `"last_15m"` |  |
| monitors.sqsBacklog.critical | int | `50` |  |
| monitors.sqsBacklog.enabled | bool | `false` | Enable the SQS backlog monitor |
| monitors.sqsBacklog.priority | int | `3` |  |
| monitors.sqsBacklog.window | string | `"last_15m"` |  |
| monitors.sqsOldestMessageAge.critical | int | `60` |  |
| monitors.sqsOldestMessageAge.enabled | bool | `false` | Enable the SQS oldest message age monitor |
| monitors.sqsOldestMessageAge.priority | int | `2` |  |
| monitors.sqsOldestMessageAge.window | string | `"last_10m"` |  |
| renotifyInterval | int | `0` | Minutes between re-notifications while a monitor stays in alert. 0 disables re-notification. |
| scope.kubeNamespace | string | `""` | Kubernetes namespace the workload and HPA monitors filter on. Required when any of them is enabled. |
| scope.sqsQueues | list | `[]` | SQS queue names the SQS monitors filter on. Required when any of them is enabled. |
| team | string | `""` | Owning team. Rendered as the `team:` tag that notification rules route on. Required. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v0.1.0](https://github.com/norwoodj/helm-docs/releases/v0.1.0)
