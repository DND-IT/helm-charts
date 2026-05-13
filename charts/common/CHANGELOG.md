# Changelog

All notable changes to the common Helm library chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2026-05-13

### Changed

- **BREAKING:** Removed all Datadog-specific behavior from the common library. `common.datadogLabels` is gone; `common.commonEnvVars` no longer appends `DD_AGENT_HOST`, `DD_ENTITY_ID`, `DD_SERVICE`, `DD_ENV`, or `DD_VERSION`; the `datadog:` values block is removed. `common.labels` no longer takes a `pod` flag.
- Datadog unified service tagging now belongs in the wrapper charts (web/worker/task) — they set `admission.datadoghq.com/enabled` and `tags.datadoghq.com/*` via `commonLabels` defaults, and rely on the Datadog admission controller to inject `DD_AGENT_HOST` and the unified service tagging env vars at admission time. This fixes APM ingest on clusters whose admission controller uses a Service or UDS instead of a node-local `hostIP:8126` (see issue #168).

### Migration

If you were setting `datadog.service`, `datadog.env`, `datadog.version`, or relying on `datadog.enabled`, move those values onto `commonLabels` in your release values:

```yaml
commonLabels:
  admission.datadoghq.com/enabled: "true"
  tags.datadoghq.com/service: my-service
  tags.datadoghq.com/env: dev-titan
  tags.datadoghq.com/version: "1.2.3"
```

To opt out entirely, override `commonLabels` and unset the `admission.datadoghq.com/enabled` key.

## [1.7.0] - 2026-05-11

### Changed

- **BREAKING:** `common.cronjob` is no longer a root-values renderer — it is now a parameterized helper that renders a single CronJob from `(name, config, root)`. The loader no longer calls it directly. Declare CronJobs through the `cronjobs:` map; `common.cronjobs` is the only entry point.
- **BREAKING:** Removed root-level singular CronJob keys (`schedule`, `job`, `concurrencyPolicy`, `successfulJobsHistoryLimit`, `failedJobsHistoryLimit`, `startingDeadlineSeconds`, `suspend`) from the common library defaults. Move these onto entries under `cronjobs:`. `backoffLimit`/`ttlSecondsAfterFinished` now live directly on the entry (no nested `job:` key).
- `common.job` extracted as a parameterized helper alongside `common.jobs`; same shape as `common.cronjob`/`common.cronjobs`.
- Plural `cronjobs:` and `jobs:` map entries now inherit root defaults — `configMap.envFrom`, `volumes.secret.*`/`volumes.emptyDir.*`, `commonEnvVars`, `extraEnv`, `resources`, `image` — same as the old singular path used to.
- `common.labels` now emits the Datadog tagging labels (`tags.datadoghq.com/*` via `common.datadogLabels`) *before* `commonLabels` and `pod.labels`. YAML last-key-wins means values set in `commonLabels` or `pod.labels` now override the chart's auto-injected defaults — letting consumers tag the Deployment (for kube-state-metrics) and the Pod template from a single `commonLabels` block. No behavior change when nothing is overridden.

### Migration

Before:

```yaml
schedule: "0 * * * *"
command: ["bin/run", "thing"]
job:
  backoffLimit: 1
```

After:

```yaml
cronjobs:
  thing:
    enabled: true
    schedule: "0 * * * *"
    command: ["bin/run", "thing"]
    backoffLimit: 1
```

## [1.6.0] - 2026-05-05

### Added

- **`timeZone` support in the single-cronjob template** — `_cronjob.tpl` now renders `spec.timeZone` when `.Values.timeZone` is set, matching the behavior already present in the multi-cronjob template (`_cronjobs.tpl`). Use any IANA timezone (e.g. `Europe/Zurich`) to keep schedules stable across DST transitions. Requires Kubernetes 1.27+.

## [1.5.2] - 2026-04-14

### Fixed

- `datadog.env` no longer silently falls back to the release namespace. When unset, the `tags.datadoghq.com/env` pod label and the `DD_ENV` downward-API env var are omitted entirely, so pods no longer get `DD_ENV` values like `titan-dev-titan-api`. Teams should set `datadog.env` explicitly (e.g., `dev-titan`, `prod-titan`).

## [1.5.1] - 2026-04-02

### Added

- **`volumes.secret`** — mount Kubernetes Secrets as volumes using the same map syntax as `volumes.emptyDir`. Supports `secretName` (defaults to key name), `items`, `defaultMode`, `mountPath`, `subPath`, and `readOnly`
- Added commented examples to all values.yaml keys for discoverability

## [1.5.0] - 2026-03-27

### Added

- **`port` value** — single source of truth for the container port. Automatically flows to container port, service targetPort, and TargetGroupConfiguration healthCheckPort. Set `port: 3001` and everything updates. `ports` array still works for advanced multi-port setups
- **`env` map** — environment variables as a simple map (`env.LOG_LEVEL: info`). Merges via Helm deep merge, so consuming charts keep defaults. Set to `null` to disable a default (e.g., `env.LOG_FORMAT: null`). Defaults: `TZ=UTC`, `LOG_FORMAT=json`
- **`extraEnv` list** — environment variables as a Kubernetes EnvVar list, for `valueFrom`/`secretKeyRef`/`configMapKeyRef` cases
- **`secret.defaultMode`** — configurable file permissions for mounted secret volumes (default: `420`/`0644`). Previously hardcoded in templates
- `PORT` env var now picks up the `port` value (previously only read from `ports` array)

### Changed

- Service port defaults to `port` value when `service.port` is not set (wrapper charts like `web` set their own `service.port` default)
- TargetGroupConfiguration `healthCheckPort` is now auto-derived from `port` value when not explicitly set in `healthCheckConfig`
- Secret volume `defaultMode` for `extraSecrets` falls back to `secret.defaultMode` from values, with per-secret override support
- Hardcoded env vars (`TZ`, `LOG_FORMAT`) moved from templates to `env` map in values.yaml
- `env` changed from list to map format; list-style env vars now use `extraEnv`

## [1.4.2] - 2026-03-24

### Fixed

- Security context fields with falsy values (`false`, `0`) were silently dropped due to `else if` truthiness checks in `_security.tpl` — changed to unconditional `else` for `runAsNonRoot`, `runAsUser`, `runAsGroup`, `fsGroup`, `fsGroupChangePolicy`
- Default security context overrides with falsy values (e.g., `defaultPodSecurityContext.runAsNonRoot: false`) were ignored because `| default` treated them as empty — replaced with `hasKey`/`ternary` pattern
- Removed `runAsNonRoot` and `runAsUser` from `defaultContainerSecurityContext` — these are inherited from pod security context via Kubernetes and were unnecessarily overriding pod-level settings

## [1.4.1] - 2026-03-20

### Changed

- Top-level `resources` now renders at pod level on K8s >= 1.34 and container level on K8s < 1.34 (auto-detected via `semverCompare`)
- Gateway API parentRefs now default to `group: gateway.networking.k8s.io`, `kind: Gateway`
- Gateway API backendRefs now default to `group: ""`, `kind: Service`, `weight: 1`

## [1.4.0] - 2026-03-18

### Added

- StatefulSet workload type support (`workload.type: statefulset`) with `serviceName`, `volumeClaimTemplates`, `podManagementPolicy`, `updateStrategy`, `ordinals`, and `persistentVolumeClaimRetentionPolicy`
- DaemonSet workload type support (`workload.type: daemonset`) with `updateStrategy`
- Automatic volume mount generation for StatefulSet `volumeClaimTemplates`
- `statefulset` and `daemonset` values sections in `values.yaml`

### Changed

- HPA `scaleTargetRef.kind` now dynamically resolves based on `workload.type` (supports Deployment and StatefulSet, excludes DaemonSet)
- VPA `targetRef.kind` now correctly renders `StatefulSet` and `DaemonSet` (fixed `title` casing bug)
- `common.validateValues` now validates `image.repository` for all workload types

### Fixed

- PVC and volume rendering now correctly honors `enabled: false` on persistent volumes (previously `false | default true` evaluated to `true`)

## [1.3.0] - 2026-03-17

### Added

- Commented-out examples in `values.yaml` for all major configuration sections: volumes, extraDeployments, cronjobs, jobs, extraServices, extraIngresses, rbac, extraConfigMaps, extraSecrets, externalSecrets, hpa, vpa, networkPolicy, all Gateway API routes, targetGroupBinding, hooks, and extraObjects

### Fixed

- Fixed invalid TargetGroupConfiguration health check field names in commented examples (`healthCheckIntervalSeconds` → `healthCheckInterval`)

## [1.2.0] - 2026-03-13

### Changed

- **Refactored workload templates to use composition hierarchy.** CronJob, Job, and Hook templates now delegate to `common.podTemplate` and `common.container` instead of reimplementing pod/container specs inline. This eliminates ~520 lines of duplicated code and ensures all workload types automatically inherit pod features (hostAliases, dnsPolicy, priorityClassName, topologySpreadConstraints, sidecar containers, etc.) and consistent security context defaults.
- **Extracted Gateway API shared helpers.** Created `common.gatewayParentRefs`, `common.gatewayBackendRef`, and `common.gatewayFilters` helpers to deduplicate parentRef, backendRef, and filter rendering across all 5 route types (HTTPRoute, GRPCRoute, TCPRoute, TLSRoute, UDPRoute).

### Added

- `common.jobSpec` helper for shared Job spec fields (completions, parallelism, backoffLimit, activeDeadlineSeconds, ttlSecondsAfterFinished, completionMode, suspend, podFailurePolicy)
- `common.gatewayParentRefs` helper for rendering parentRef list items across all route types
- `common.gatewayBackendRef` helper for rendering backendRef fields across all route types
- `common.gatewayFilters` helper for rendering filter lists (HTTPRoute and GRPCRoute)
- `defaultRestartPolicy` parameter on `common.podTemplate` for caller-specified defaults
- `mainContainer` parameter on `common.container` for main container behavior (envFrom, volumeMounts, commonEnvVars, service port fallback)
- `containerName` parameter on `common.container` for explicit container name override

## [1.0.1] - 2026-02-20

### Fixed

- `common.tplYaml`: Use `toYaml` for annotation/label values to properly quote numeric-looking strings (fixes kubeconform validation errors for Ingress annotations)

## [1.0.0] - 2026-02-10

### Added

- Initial release of common library chart
- Extracted shared helpers from generic chart:
  - `_names.tpl`: common.name, common.fullname, common.chart, common.namespace, common.serviceAccountName, common.configMapName, common.secretName, common.pvcName
  - `_labels.tpl`: common.labels, common.selectorLabels, common.annotations, common.podSecurityStandardsLabels
  - `_template.tpl`: common.tplValue, common.tplYaml, common.apiVersion
  - `_image.tpl`: common.image, common.resolveStringImage, common.containerImage
  - `_security.tpl`: common.podSecurityContext, common.containerSecurityContext, common.securityAnnotations, common.networkPolicySelector
  - `_env.tpl`: common.envVars, common.commonEnvVars, common.envFrom
  - `_container.tpl`: common.container, common.sidecarContainer
  - `_volumes.tpl`: common.volumes, common.volumeMounts
  - `_pod.tpl`: common.podTemplate, common.podAnnotations, common.topologySpreadConstraints, common.servicePort, common.serviceTargetPort, common.servicePortName, common.validateValues
- Secure defaults for pod and container security contexts
- Support for global.registry override
