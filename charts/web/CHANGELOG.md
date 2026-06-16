# Changelog

All notable changes to the web Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.1] - 2026-07-01

### Changed

- Picks up `common` 1.10.0, which adds a `values.schema.json` to the library so the `common:` values block is now schema-validated.

## [1.6.0] - 2026-06-30

### Changed

- Picks up `common` 1.9.0: a persistent volume's `storageClass` is now rendered as a template, so a PVC can point at a release-scoped StorageClass created via `extraObjects` (useful for CSI volumes like EFS / S3 Files whose StorageClass embeds infra IDs and must stay unique across PR-preview releases). Existing plain `storageClass` values (e.g. `gp3`) are unaffected.

## [1.5.0] - 2026-05-13

### Changed

- **BREAKING:** Datadog labels now ship as chart defaults under `commonLabels` instead of being injected by the `common` library. The chart sets `admission.datadoghq.com/enabled: "true"` and templated `tags.datadoghq.com/service` / `tags.datadoghq.com/version`. `DD_AGENT_HOST` is no longer hard-coded — the Datadog admission controller injects it (and the DD_* env vars) at admission time, so APM works on clusters that route via a per-namespace Service or UDS instead of `<hostIP>:8126` (see issue #168).
- Picks up `common` 1.8.0 — the `datadog:` values block, `common.datadogLabels`, and DD_* downward-API env vars are gone from the library. If you were setting `datadog.service` / `datadog.env` / `datadog.version`, move them onto `commonLabels.tags.datadoghq.com/*` in your release values.
- HPA enabled by default with CPU @ 80% utilization (minReplicas 2, maxReplicas 10). Set `hpa.enabled: false` to opt out, or override `hpa.metrics` to add memory/custom signals.
- PodDisruptionBudget enabled by default with `minAvailable: 1`, paired with the HPA `minReplicas: 2` so rollouts and node drains keep one pod up.

## [1.4.0] - 2026-05-11

### Changed

- Updated to common library 1.7.0. Cronjob/job rendering was refactored (see common CHANGELOG); web chart does not declare cronjobs so no values changes are required.

## [1.3.3] - 2026-04-14

### Fixed

- Picks up `common` 1.5.2: `tags.datadoghq.com/env` label and `DD_ENV` env var are omitted when `datadog.env` is empty (no more namespace fallback). Set `datadog.env` explicitly (e.g. `dev-titan`).

## [1.3.2] - 2026-04-08

### Fixed

- Probe `port` schema now accepts both string (named port) and integer — matches Kubernetes IntOrString

## [1.3.1] - 2026-04-02

### Added

- `volumes.secret` support for mounting Kubernetes Secrets as volumes
- Updated to common library 1.5.1

## [1.3.0] - 2026-04-01

### Changed

- `env` changed from list to map format — merges with common defaults via Helm deep merge
- Added `extraEnv` list for `valueFrom`/`secretKeyRef` cases
- `port` value as single source of truth for container port and service targetPort
- Updated to common library 1.5.0

## [1.2.2] - 2026-03-20

### Changed

- Disable `LoadBalancerConfiguration` by default — most deployments use shared load balancers
- Updated parentRefs example to include `group` and `kind` fields

## [1.2.1] - 2026-03-17

### Fixed

- Fixed invalid `TargetGroupConfiguration` health check field names that caused `SyncFailed` errors in ArgoCD (`healthCheckTimeoutSeconds` → removed, `healthCheckIntervalSeconds` → `healthCheckInterval`)

## [1.1.0] - 2026-03-05

### Added

- Datadog Admission Controller pod label enabled by default

## [1.0.0] - 2026-02-10

### Added

- Initial release of web chart for HTTP-facing applications
- Built on common library chart for shared functionality
- Includes Deployment, Service, Ingress (enabled by default), HPA, PDB, ServiceAccount
- Simplified values.yaml with sensible defaults for web applications
- Ingress enabled by default with ALB ingress class
- Secure defaults for pod and container security contexts
- Support for topology spread constraints
- Health checks with liveness and readiness probes
