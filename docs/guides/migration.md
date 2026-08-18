# Migrating from Deprecated Charts

The `webapp` and `cronjob` charts are deprecated. Use `web` and `task` instead.

## webapp to web

### Before You Start: 3 Breaking Changes

**1. Immutable Deployment Selector**

`webapp` uses selector labels `type: webapp` + `app: <name>`. `web` uses `app.kubernetes.io/name`, `/instance`, and `/component: main`. Kubernetes forbids changing a Deployment's `spec.selector` — `helm upgrade` will fail with `field is immutable`.

**Solution:** Use blue/green deployment with a new release name. Install `web` under `<release>-v2`, verify it's healthy, shift traffic at the ALB/Gateway, then uninstall the old `webapp` release. This avoids downtime.

```bash
# Install new release alongside old
helm install my-app-v2 dnd-it/web -f values.yaml

# Verify pods are ready
kubectl rollout status deployment/my-app-v2

# Shift traffic at ALB target group or Gateway HTTPRoute
# (update your DNS or load balancer routing)

# Once traffic is stable, uninstall old release
helm uninstall my-app

# Optional: reinstall under original name if desired
helm install my-app dnd-it/web -f values.yaml
```

**2. Hardened Pod Security Defaults**

`web` enforces `runAsNonRoot: true`, `runAsUser: 1000`, `readOnlyRootFilesystem: true`, and drops all Linux capabilities. This breaks:
- Images that run as root
- Apps writing to `/tmp` or other writable paths
- Privileged operations (e.g., `iptables`, `mount`)

**Solution:** Add an `emptyDir` for `/tmp` and override security context if needed.

```yaml
# Add to values.yaml
volumes:
  tmp:
    emptyDir: {}

pod:
  volumeMounts:
    - name: tmp
      mountPath: /tmp

# If your image must run as root (not recommended):
security:
  defaultPodSecurityContext:
    runAsNonRoot: false
    runAsUser: 0
```

**3. Service Port 80 → 8080**

`webapp` exposes the Service on port 80. `web` uses port 8080. This breaks:
- Hardcoded port 80 references in NetworkPolicies, other charts, or manual target groups
- Ingress/Gateway configurations that hardcode port 80 (though the default Ingress backend uses port name `http`, so it's transparent)

**Solution:** Update any hardcoded port 80 references to 8080. For Ingress/Gateway, use port names (`http`) instead of numbers.

---

### Phase 1: Chart Swap (Keep ALB Ingress)

Migrate to `web` while staying on ALB Ingress. This is a smaller, reversible step before moving to Gateway API.

#### 1. Update Chart.yaml

```yaml
dependencies:
  - name: web
    version: "1.x.x"
    repository: "oci://ghcr.io/dnd-it/helm-charts"
```

#### 2. Complete Value Mapping

| webapp | web | Notes |
|--------|-----|-------|
| `image_repo` | `image.repository` | |
| `image_tag` | `image.tag` | |
| `image_pull_policy` | `image.pullPolicy` | |
| `replicas` | `replicas` | Unchanged |
| `revisionHistoryLimit` | `revisionHistoryLimit` | Unchanged |
| `scale.enabled` | `hpa.enabled` | |
| `scale.minReplicas` | `hpa.minReplicas` | |
| `scale.maxReplicas` | `hpa.maxReplicas` | |
| `scale.cpuThresholdPercentage` | `hpa.metrics[0].resource.target.averageUtilization` | Set to 80 for 100% CPU threshold |
| `scale.memoryThresholdPercentage` | `hpa.metrics[1]` (add new entry) | Add memory metric if needed |
| `scale.minAvailable` | `podDisruptionBudget.minAvailable` | |
| `update.maxUnavailable` | `strategy.rollingUpdate.maxUnavailable` | |
| `update.maxSurge` | `strategy.rollingUpdate.maxSurge` | |
| `command` | `command` | Unchanged |
| `args` | `args` | Unchanged |
| `env` | `env` | Map form, unchanged |
| `extraEnvFrom` | `extraEnvFrom` | Unchanged |
| `extraObjects` | `extraObjects` | Now also accepts map form (keyed by name) |
| `probe.liveness` | `livenessProbe.httpGet.path` | Default `/livez` (was `/`) |
| `probe.livenessInitialDelaySeconds` | `livenessProbe.initialDelaySeconds` | Default 30 (was 0) |
| `probe.livenessPeriodSeconds` | `livenessProbe.periodSeconds` | Unchanged |
| `probe.livenessTimeoutSeconds` | `livenessProbe.timeoutSeconds` | Unchanged |
| `probe.readiness` | `readinessProbe.httpGet.path` | Default `/readyz` (was `/`) |
| `probe.readinessInitialDelaySeconds` | `readinessProbe.initialDelaySeconds` | Default 5 (was 0) |
| `probe.readinessPeriodSeconds` | `readinessProbe.periodSeconds` | Unchanged |
| `probe.readinessTimeoutSeconds` | `readinessProbe.timeoutSeconds` | Unchanged |
| `probe.readinessFailureThreshold` | `readinessProbe.failureThreshold` | Unchanged |
| `probe.startup` | `startupProbe.httpGet.path` | Default `/readyz` (was liveness path) |
| `probe.startupHttpHeaders` | `startupProbe.httpGet.httpHeaders` | Unchanged |
| `probe.grpc` | `livenessProbe.grpc` / `readinessProbe.grpc` / `startupProbe.grpc` | Unchanged structure |
| `service.enabled` | `service.enabled` | Unchanged |
| `service.type` | `service.type` | Unchanged |
| `service.port` | `service.port` | **Now 8080** (was 80) |
| `service.targetPort` | `port` | Set `port: 8080` at root level |
| `service.portName` | (derived as `http`) | Automatic |
| `service.annotations` | `service.annotations` | Unchanged |
| `service.trafficDistribution` | `service.trafficDistribution` | Unchanged |
| `ingress.enabled` | `ingress.enabled` | Unchanged |
| `ingress.className` | `ingress.ingressClassName` | |
| `ingress.annotations` | `ingress.annotations` | Unchanged |
| `ingress.hosts` | `ingress.hosts[].host` / `.paths[].path` / `.paths[].pathType` | Nested structure |
| `ingress.paths` | (see above) | |
| `ingress.pathType` | (see above) | |
| `ingress.tls` | `ingress.tls` | Unchanged |
| `resources` | `resources` | Pod-level on K8s ≥1.34 (was container-level) |
| `nodeSelector` | `scheduling.nodeSelector` | |
| `tolerations` | `scheduling.tolerations` | |
| `affinity` | `scheduling.affinity` | |
| `topologySpreadConstraints` | `scheduling.topologySpreadConstraints` | Selector labels auto-injected; no manual `labelSelector` needed |
| `serviceAccountName` | `serviceAccount.name` | |
| `deploymentServiceAccountName` | (not needed) | Use `serviceAccount.name` |
| `aws_iam_role_arn` | `serviceAccount.annotations."eks.amazonaws.com/role-arn"` | |
| `metadata.deploymentAnnotations` | `workloadAnnotations` | |
| `metadata.podAnnotations` | `pod.annotations` | |
| `metadata.hpaAnnotations` | `hpa.annotations` | |
| `metadata.labels.datadog.*` | (delete) | Automatic via `commonLabels` + admission controller |
| `initContainer.*` (single object) | `initContainers: []` (list) | Convert to list form |
| `externalSecrets.secretNames` | `externalSecrets` (map) | **See section below** |
| `externalSecrets.refreshInterval` | `externalSecrets.<name>.refreshInterval` | Per-entry |
| `externalSecrets.clusterSecretStore` | `externalSecrets.<name>.secretStoreRef.name` | Per-entry |
| `externalSecrets.annotations` | `externalSecrets.<name>.annotations` | Per-entry |
| `targetGroupBinding.enabled` | `targetGroupBinding.enabled` | Unchanged |
| `targetGroupBinding.targetGroupARN` | `targetGroupBinding.targetGroupARN` | Unchanged |
| `targetGroupBinding.annotations` | `targetGroupBinding.annotations` | Unchanged |

#### 3. External Secrets: The Detailed Rewrite

`webapp` auto-generates `ExternalSecret` resources from a simple list of secret names and auto-wires them to `envFrom`. `web` uses a structured map where you define the full spec and opt-in to `envFrom`.

**Old (webapp):**
```yaml
externalSecrets:
  secretNames:
    - prod/my-app/database
    - prod/my-app/api-keys
  refreshInterval: 5m
  clusterSecretStore: aws-secretsmanager
```

This auto-creates two `ExternalSecret` resources with `dataFrom.extract` and auto-injects both into `envFrom`.

**New (web):**
```yaml
externalSecrets:
  database:
    enabled: true
    refreshInterval: 5m
    secretStoreRef:
      name: aws-secretsmanager
      kind: ClusterSecretStore
    target:
      name: database  # Secret name in cluster
      creationPolicy: Owner
    dataFrom:
      - extract:
          key: prod/my-app/database
    envFrom: true  # Opt-in to envFrom injection
  api-keys:
    enabled: true
    refreshInterval: 5m
    secretStoreRef:
      name: aws-secretsmanager
      kind: ClusterSecretStore
    target:
      name: api-keys
      creationPolicy: Owner
    dataFrom:
      - extract:
          key: prod/my-app/api-keys
    envFrom: true
```

Key differences:
- Each secret is a map entry (keyed by name, e.g., `database`, `api-keys`)
- `envFrom: true` is **explicit per entry** (not automatic)
- Secret names are no longer auto-lowercased or slash-replaced — you control the target name via `target.name`
- `secretStoreRef` is per-entry, not global

#### 4. Init Containers: Convert to List Form

**Old (webapp):**
```yaml
initContainer:
  enabled: true
  name: init-perms
  image: busybox
  image_tag: latest
  command: ["sh", "-c", "chown -R 1000:1000 /app"]
  args: []
  env: {}
  extraEnvFrom: []
```

**New (web):**
```yaml
initContainers:
  - name: init-perms
    image: busybox:latest
    command: ["sh", "-c", "chown -R 1000:1000 /app"]
    # Full Kubernetes container spec; see common library docs
```

#### 5. Datadog: Remove Manual Labels

`web` automatically injects Datadog unified service tagging via `commonLabels` and the admission controller. Delete these from your values:

```yaml
# DELETE these:
metadata:
  labels:
    datadog:
      env: ""
      service: ""
      version: ""

# DELETE manual DD_* env vars:
env:
  DD_ENV: ""
  DD_SERVICE: ""
  DD_VERSION: ""
```

The admission controller will inject them at pod admission time.

#### 6. Security Contexts: Remove Manual Overrides

`web` defaults to `runAsNonRoot: true`, `runAsUser: 1000`, `readOnlyRootFilesystem: true`, drop all caps. If you had manual overrides, delete them:

```yaml
# DELETE these:
pod:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
```

If your image needs different security settings, override at the root level:

```yaml
security:
  defaultPodSecurityContext:
    runAsNonRoot: false
    runAsUser: 0
```

#### 7. Phase 1 Values Template

```yaml
# Minimal Phase 1 values.yaml (Ingress, no Gateway API)
image:
  repository: my-org/my-app
  tag: "1.0.0"

port: 8080

# Disable Gateway API for now
gateway:
  httpRoute:
    enabled: false
  targetGroupConfiguration:
    enabled: false

# Enable ALB Ingress
ingress:
  enabled: true
  ingressClassName: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

# Autoscaling
hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 10

# Pod disruption budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Scheduling
scheduling:
  nodeSelector:
    kubernetes.io/arch: amd64
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway

# Service account + IRSA
serviceAccount:
  name: my-app
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/my-app-role

# Environment variables
env:
  LOG_LEVEL: info

# External secrets (if needed)
externalSecrets:
  database:
    enabled: true
    refreshInterval: 5m
    secretStoreRef:
      name: aws-secretsmanager
      kind: ClusterSecretStore
    target:
      name: database
      creationPolicy: Owner
    dataFrom:
      - extract:
          key: prod/my-app/database
    envFrom: true
```

---

### Phase 2: Ingress → Gateway API

Once Phase 1 is stable, migrate to Gateway API for better traffic management and AWS Load Balancer Controller v3 features.

```yaml
# Disable Ingress
ingress:
  enabled: false

# Enable Gateway API
gateway:
  httpRoute:
    enabled: true
    parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: public-gateway
        namespace: gateway-system
    hostnames:
      - myapp.example.com
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /
        backendRefs:
          - name: my-app  # Release name
            port: 8080

  targetGroupConfiguration:
    enabled: true
    defaultConfiguration:
      targetType: ip
      protocolVersion: HTTP1
      healthCheckConfig:
        healthCheckPath: /readyz
        healthCheckProtocol: HTTP
        healthCheckInterval: 15
        healthyThresholdCount: 2
        unhealthyThresholdCount: 3

  loadBalancerConfiguration:
    enabled: true
```

---

### Verification

**1. Template diff:**
```bash
helm template my-app-v2 dnd-it/web -f values.yaml > new.yaml
helm template my-app dnd-it/webapp -f old-values.yaml > old.yaml
diff -u old.yaml new.yaml | head -100
```

**2. Dry-run apply:**
```bash
helm install my-app-v2 dnd-it/web -f values.yaml --dry-run=server
```

**3. Rollout check:**
```bash
kubectl rollout status deployment/my-app-v2 --timeout=5m
kubectl get pods -l app.kubernetes.io/instance=my-app-v2 -o wide
```

**4. Probe health:**
```bash
kubectl describe pod -l app.kubernetes.io/instance=my-app-v2 | grep -A5 "Liveness\|Readiness"
```

**5. Service port:**
```bash
kubectl get svc my-app-v2 -o jsonpath='{.spec.ports[0].port}'
# Should output: 8080
```

---

## cronjob to task

### Key Differences

| Feature | cronjob (old) | task (new) |
|---------|--------------|------------|
| Library | Standalone templates | Common library |
| Security | Manual configuration | Secure by default |
| Resources | Container-level | Pod-level |
| Defaults | Minimal | Opinionated (concurrency, history, TTL) |

### Migration Steps

1. **Update Chart.yaml dependency**:

    ```yaml
    dependencies:
      - name: task
        version: "1.x.x"
        repository: "oci://ghcr.io/dnd-it/helm-charts"
    ```

2. **Map values**:

    ```yaml
    # Old (cronjob)
    schedule: "0 * * * *"
    image:
      repository: my-app
      tag: "1.0.0"

    # New (task) - same structure, more defaults included
    schedule: "0 * * * *"
    image:
      repository: my-app
      tag: "1.0.0"
    # concurrencyPolicy, history limits, job config all have defaults now
    ```
