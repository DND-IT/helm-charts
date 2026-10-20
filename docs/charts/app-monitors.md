# App Monitors Chart

Shared Datadog monitors for one application in one environment. Each monitor is rendered as a `DatadogMonitor` resource, and the [Datadog Operator](https://docs.datadoghq.com/containers/datadog_operator/) creates it in Datadog.

The chart fixes the query of each monitor. An application turns monitors on and sets thresholds and windows. For a monitor with a different query, use [datadog-resources](datadog-resources.md).

## Monitors

| Key | Default | Scope |
|-----|---------|-------|
| `podRestarts` | on | `scope.kubeNamespace` |
| `oomKilled` | on | `scope.kubeNamespace` |
| `replicasNotReady` | on | `scope.kubeNamespace` |
| `hpaMaxedOut` | off | `scope.kubeNamespace` |
| `sqsOldestMessageAge` | off | `env` + `scope.sqsQueues` |
| `sqsBacklog` | off | `env` + `scope.sqsQueues` |

Each resource is named `<app>-<env>-<monitor>`.

## Usage

Add the chart as a dependency of the application's umbrella chart:

```yaml
# Chart.yaml
dependencies:
  - name: app-monitors
    repository: https://dnd-it.github.io/helm-charts
    version: 0.1.0
    condition: app-monitors.enabled
```

```yaml
# values.yaml
app-monitors:
  enabled: true
  team: <team>
  app: <app>
  env: <env>
  repository: <repository>
  scope:
    kubeNamespace: <namespace>
    sqsQueues:
      - <queue-name>
  monitors:
    oomKilled:
      severity: critical
      priority: 2
    sqsBacklog:
      enabled: true
      critical: 100
      warning: 60
```

`warning`, `severity` and `priority` are optional per monitor and not rendered when unset.

## Tags

Messages have no `@` handles. Datadog notification rules route alerts on the tags. Every monitor gets:

- `team:<team>`
- `env:<env>`
- `service:<app>`
- `repository:<repository>`
- `managed-by:app-monitors`
- `severity:<severity>`, when the monitor sets `severity`
- each entry of `extraTags`

The render fails when `team`, `app`, `env` or `repository` is missing, or when an enabled monitor's scope is empty.

See the [chart README](https://github.com/DND-IT/helm-charts/tree/main/charts/app-monitors) for all values.
