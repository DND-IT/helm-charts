# Web Chart

Opinionated chart for **external-facing HTTP applications**. Pre-configured with Gateway API routing, AWS ALB integration, health probes, and topology spread.

## What's Pre-configured

| Setting | Default |
|---------|---------|
| Port | 8080 (HTTP) |
| Service | ClusterIP, enabled |
| HTTPRoute | Enabled |
| Target Group | IP target type, health check on `/readyz:8080` |
| Load Balancer | internet-facing |
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
  repository: my-registry/my-web-app
  tag: "1.0.0"

gateway:
  httpRoute:
    parentRefs:
      - name: my-gateway
        namespace: gateway-system
    hostnames:
      - myapp.example.com
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /
        backendRefs:
          - name: my-web-app
            port: 80
```

## Full Example

```yaml
image:
  repository: my-registry/my-web-app
  tag: "1.0.0"

replicas: 3

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    memory: 512Mi

env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: url

gateway:
  httpRoute:
    parentRefs:
      - name: public-gateway
        namespace: gateway-system
    hostnames:
      - myapp.example.com
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /
        backendRefs:
          - name: my-web-app
            port: 80

  targetGroupConfiguration:
    defaultConfiguration:
      healthCheckConfig:
        healthCheckPath: /readyz
        healthCheckPort: "8080"

  loadBalancerConfiguration:
    scheme: internet-facing

hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

## Customizing Probes

Override the default probe endpoints if your app uses different paths:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 15

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
```

## Differences from API Chart

The web chart is nearly identical to the API chart, with these key differences:

- **HTTPRoute** is enabled by default (API has it disabled)
- **TargetGroupConfiguration** is enabled by default
- **LoadBalancerConfiguration** uses `internet-facing` scheme (API uses `internal`)
