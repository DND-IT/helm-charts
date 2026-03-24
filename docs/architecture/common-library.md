# Common Library

The common library chart (`charts/common`) is a Helm **library chart** (type: `library`) that cannot be installed directly. It provides shared templates, helpers, and secure defaults consumed by all application charts.

## Loader Pattern

Every consuming chart has a single template file:

```yaml
# charts/web/templates/common.yaml
{{- include "common.loader.generate" . -}}
```

The loader:

1. Initializes values via [deep merge](values-deep-merge.md)
2. Validates required values
3. Renders all enabled resources with YAML document separators

```go
{{- define "common.loader.generate" -}}
  {{- include "common.values.init" . -}}
  {{- include "common.validateValues" . -}}

  {{- include "common.loader.renderResource" (include "common.serviceAccount" .) }}
  {{- include "common.loader.renderResource" (include "common.rbac" .) }}
  {{- include "common.loader.renderResource" (include "common.configmap" .) }}
  {{- include "common.loader.renderResource" (include "common.secret" .) }}
  {{- include "common.loader.renderResource" (include "common.deployment" .) }}
  {{- include "common.loader.renderResource" (include "common.service" .) }}
  ...
{{- end -}}
```

The `renderResource` helper adds `---` document separators and trims empty output:

```go
{{- define "common.loader.renderResource" -}}
  {{- $content := . | trim -}}
  {{- if $content -}}
    {{- if hasPrefix "---" $content }}
{{ $content }}
    {{- else }}
---
{{ $content }}
    {{- end -}}
  {{- end -}}
{{- end -}}
```

## Helper Functions

### Naming

| Function | Output |
|----------|--------|
| `common.name` | Chart name or `nameOverride` |
| `common.fullname` | Release-name-chart or `fullnameOverride` |
| `common.chart` | Chart name and version |
| `common.namespace` | Release namespace or `namespaceOverride` |
| `common.serviceAccountName` | Service account name |

### Labels

```yaml
# common.labels - all resources
helm.sh/chart: web-1.2.0
app.kubernetes.io/name: web
app.kubernetes.io/instance: my-app
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/version: "1.0.0"

# common.selectorLabels - deployments and services
app.kubernetes.io/name: web
app.kubernetes.io/instance: my-app
```

Pod templates get additional Datadog labels when `datadog.enabled: true`:

```yaml
admission.datadoghq.com/enabled: "true"
tags.datadoghq.com/service: my-app
tags.datadoghq.com/env: production
tags.datadoghq.com/version: "1.0.0"
```

### Images

The `common.image` helper resolves images with global registry support:

```
Priority: container registry > global.image.registry > none
Output:   [registry/]repository:tag
```

### Security Contexts

Default pod security context:

```yaml
runAsNonRoot: true
runAsUser: 1000
runAsGroup: 1000
fsGroup: 1000
fsGroupChangePolicy: OnRootMismatch
seccompProfile:
  type: RuntimeDefault
```

Default container security context:

```yaml
runAsNonRoot: true
runAsUser: 1000
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop: [ALL]
seccompProfile:
  type: RuntimeDefault
```

Security context templates use `hasKey` checks to correctly handle falsy values. This means you can set fields like `runAsNonRoot: false`, `runAsUser: 0`, or `fsGroup: 0` and they will be rendered as-is — they are not silently dropped or overridden by defaults.

The same applies to `security.defaultPodSecurityContext` and `security.defaultContainerSecurityContext`: falsy values in defaults (e.g., `runAsNonRoot: false`) are respected and not replaced by hardcoded fallbacks.

## Composition Hierarchy

All workload types share the same composition chain:

```
Deployment  → common.podTemplate → common.container
CronJob     → common.jobSpec → common.podTemplate → common.container
Job         → common.jobSpec → common.podTemplate → common.container
Hook        → common.podTemplate → common.container
```

This means Jobs, CronJobs, and Hooks automatically inherit every pod-level feature that Deployments support: hostAliases, dnsPolicy, priorityClassName, topologySpreadConstraints, sidecar containers, and consistent security context defaults.

### Pod Template

The `common.podTemplate` helper generates a unified pod template used by all workload types. It supports:

- Pod-level resources (`resources:` at top level)
- Container-level resources (`container.resources:`)
- Common environment variables
- Datadog unified service tagging
- Init containers and native sidecar containers
- Topology spread constraints with automatic label selectors
- Volume mounts from ConfigMap, Secret, PVC, emptyDir, hostPath
- Config/secret checksum annotations for auto-reload
- `defaultRestartPolicy` parameter for caller-specified defaults (e.g., `OnFailure` for jobs, `Never` for hooks)

### Container

The `common.container` helper renders a single container spec. It supports two modes:

- **Main container** (`mainContainer: true`): Merges common env vars, uses `envFrom` helper for auto-injection from ConfigMaps/Secrets, falls back to service port when no explicit ports defined, uses `volumeMounts` helper
- **Component container** (default): Used for extra deployments, jobs, cronjobs, and hooks — renders from the config dict directly

### Job Spec

The `common.jobSpec` helper renders shared Job spec fields used by both standalone Jobs and CronJobs: `completions`, `parallelism`, `backoffLimit`, `activeDeadlineSeconds`, `ttlSecondsAfterFinished`, `completionMode`, `suspend`, `podFailurePolicy`.

## Gateway API Helpers

Route templates use shared helpers to avoid duplication across the 5 route types:

| Helper | Used By | Purpose |
|--------|---------|---------|
| `common.gatewayParentRefs` | All 5 route types | Render parentRef list items |
| `common.gatewayBackendRef` | All 5 route types | Render individual backendRef fields |
| `common.gatewayFilters` | HTTPRoute, GRPCRoute | Render filter lists (header modifiers, redirects, rewrites, mirrors, extensions) |
