# Datadog Resources Chart

Deploys Datadog observability resources as Kubernetes custom resources, managed via the [Datadog Operator](https://docs.datadoghq.com/containers/datadog_operator/).

## Resources Supported

- **DatadogMonitor** - Metric, query, and composite monitors
- **DatadogDashboard** - Dashboard definitions
- **DatadogSLO** - Service Level Objectives
- **DatadogMetric** - Custom metrics for HPA
- **DatadogDowntime** - Scheduled downtimes

## Basic Monitor

```yaml
monitors:
  high-error-rate:
    type: metric alert
    query: "avg(last_5m):sum:http.requests.errors{service:my-app} / sum:http.requests.total{service:my-app} > 0.05"
    message: |
      Error rate above 5% for {{service.name}}.
      @slack-alerts
    tags:
      - service:my-app
      - env:production
    options:
      thresholds:
        critical: 0.05
        warning: 0.02
```

## SLO

```yaml
slos:
  availability:
    type: metric
    description: "99.9% availability for my-app"
    query:
      numerator: "sum:http.requests.total{service:my-app} - sum:http.requests.errors{service:my-app}"
      denominator: "sum:http.requests.total{service:my-app}"
    thresholds:
      - timeframe: "30d"
        target: 99.9
        warning: 99.95
    tags:
      - service:my-app
```
