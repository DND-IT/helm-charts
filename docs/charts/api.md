# API Chart

Opinionated chart for **internal API services**. Pre-configured with ClusterIP service, health probes, and topology spread. Gateway API resources are defined but disabled by default.

## What's Pre-configured

| Setting | Default |
|---------|---------|
| Port | 8080 (HTTP) |
| Service | ClusterIP, enabled |
| HTTPRoute | Disabled (enable for external exposure) |
| Target Group | Disabled, pre-configured with internal defaults |
| Load Balancer | Disabled, scheme: `internal` |
| Liveness probe | `GET /livez` |
| Readiness probe | `GET /readyz` |
| Startup probe | `GET /readyz` (failureThreshold: 30) |
| Resources | 100m CPU, 128Mi memory (pod-level) |
| Node selector | `kubernetes.io/arch: amd64` |
| Topology spread | Spread across nodes and zones |
| HPA | minReplicas: 2 |
| ConfigMap | envFrom injection when enabled |

## Minimal Example

```yaml
image:
  repository: my-registry/my-api
  tag: "1.0.0"
```

This deploys an internal API with a ClusterIP service. Other services in the cluster can reach it at `my-api.<namespace>.svc.cluster.local:8080`.

## Exposing Externally

To expose an API externally, enable the Gateway API resources:

```yaml
image:
  repository: my-registry/my-api
  tag: "1.0.0"

gateway:
  httpRoute:
    enabled: true
    parentRefs:
      - name: internal-gateway
        namespace: gateway-system
    hostnames:
      - api.internal.example.com
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /v1
        backendRefs:
          - name: my-api
            port: 80

  targetGroupConfiguration:
    enabled: true

  loadBalancerConfiguration:
    enabled: true
    # Uses 'internal' scheme by default
```

## Differences from Web Chart

- **HTTPRoute** disabled by default (web has it enabled)
- **TargetGroupConfiguration** disabled by default
- **LoadBalancerConfiguration** uses `internal` scheme instead of `internet-facing`
