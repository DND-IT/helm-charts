# Quick Start

Deploy a web application in under 5 minutes.

## Minimal Web App

Create a `values.yaml`:

```yaml
image:
  repository: public.ecr.aws/nginx/nginx-unprivileged
  tag: "1.27-alpine"

ports:
  - name: http
    containerPort: 8080

# Override probes for nginx
livenessProbe:
  httpGet:
    path: /
    port: http

readinessProbe:
  httpGet:
    path: /
    port: http
```

Deploy:

```bash
helm install my-app oci://ghcr.io/dnd-it/helm-charts/web -f values.yaml
```

This gives you:

- A Deployment with secure defaults (non-root, read-only filesystem)
- A ClusterIP Service
- Gateway API HTTPRoute (ready for external traffic)
- Pod-level resource requests (100m CPU, 128Mi memory)
- Topology spread across nodes and zones
- Datadog unified service tagging
- Common environment variables (TZ, PORT, POD_NAME, etc.)

## Minimal API Service

```yaml
image:
  repository: my-registry/my-api
  tag: "1.0.0"
```

That's it. The API chart provides sensible defaults for everything:

- Port 8080 with `/livez` and `/readyz` health probes
- ClusterIP service (no external exposure)
- Resource requests and scheduling defaults

```bash
helm install my-api oci://ghcr.io/dnd-it/helm-charts/api -f values.yaml
```

## Minimal Worker

```yaml
image:
  repository: my-registry/my-worker
  tag: "1.0.0"

command: ["python"]
args: ["-m", "worker"]
```

```bash
helm install my-worker oci://ghcr.io/dnd-it/helm-charts/worker -f values.yaml
```

## Minimal CronJob

```yaml
image:
  repository: my-registry/my-task
  tag: "1.0.0"

schedule: "0 */6 * * *"

command: ["python"]
args: ["-m", "cleanup"]
```

```bash
helm install my-task oci://ghcr.io/dnd-it/helm-charts/task -f values.yaml
```

## What's Included by Default

All charts automatically provide:

| Feature | Default |
|---------|---------|
| Security context | Non-root (UID 1000), read-only root filesystem, all capabilities dropped |
| Service account | Created automatically |
| Datadog labels | `tags.datadoghq.com/service`, `env`, `version` |
| Common env vars | `TZ`, `PORT`, `POD_NAME`, `POD_NAMESPACE`, `POD_IP`, `NODE_NAME`, `DD_*` |
| Revision history | 2 revisions kept |
| Strategy | RollingUpdate (25% maxUnavailable, 25% maxSurge) |

## Next Steps

- [Charts overview](../charts/index.md) for detailed chart documentation
- [Values reference](../reference/values.md) for all available configuration
- [Security guide](../guides/security.md) to understand security defaults
