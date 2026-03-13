# Common Environment Variables

When `commonEnvVars: true` (default), the following environment variables are automatically injected into every container.

## Runtime Defaults

| Variable | Value | Description |
|----------|-------|-------------|
| `TZ` | `UTC` | Timezone |
| `LOG_FORMAT` | `json` | Log format hint |
| `PORT` | First port from `ports[]` | Application port (only if ports are defined) |

## Kubernetes Downward API

These variables are populated from the pod's metadata at runtime:

| Variable | Source | Description |
|----------|--------|-------------|
| `POD_NAME` | `metadata.name` | Name of the pod |
| `POD_NAMESPACE` | `metadata.namespace` | Namespace the pod is running in |
| `POD_IP` | `status.podIP` | IP address of the pod |
| `NODE_NAME` | `spec.nodeName` | Name of the node |
| `SERVICE_ACCOUNT` | `spec.serviceAccountName` | Service account name |

## Datadog Variables

Injected when `datadog.enabled: true` (default). These are read from pod labels via the downward API:

| Variable | Source Label | Description |
|----------|-------------|-------------|
| `DD_SERVICE` | `tags.datadoghq.com/service` | Datadog service name |
| `DD_ENV` | `tags.datadoghq.com/env` | Datadog environment |
| `DD_VERSION` | `tags.datadoghq.com/version` | Datadog version |
| `DD_AGENT_HOST` | `status.hostIP` | Datadog agent host (node IP) |
| `DD_ENTITY_ID` | `metadata.uid` | Datadog entity ID (pod UID) |

## Ordering

Common env vars are injected **before** user-defined `env:` values. This means you can override any common variable:

```yaml
env:
  - name: TZ
    value: "Europe/Zurich"     # Overrides the default UTC
  - name: LOG_FORMAT
    value: "text"              # Overrides the default json
```

## Disabling

To disable all common env vars:

```yaml
commonEnvVars: false
```

To disable only Datadog variables while keeping the rest:

```yaml
datadog:
  enabled: false
```
