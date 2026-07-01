# Changelog

All notable changes to the task Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.1] - 2026-06-16

### Changed

- Picks up `common` 1.10.0, which adds a `values.schema.json` to the library so the `common:` values block is now schema-validated.

## [1.6.0] - 2026-05-13

### Changed

- **BREAKING:** Datadog labels now ship as chart defaults under `commonLabels` instead of being injected by the `common` library. The chart sets `admission.datadoghq.com/enabled: "true"` and templated `tags.datadoghq.com/service` / `tags.datadoghq.com/version`. `DD_AGENT_HOST` is no longer hard-coded — the Datadog admission controller injects it (and the DD_* env vars) at admission time, so APM works on clusters that route via a per-namespace Service or UDS instead of `<hostIP>:8126` (see issue #168).
- Picks up `common` 1.8.0 — the `datadog:` values block, `common.datadogLabels`, and DD_* downward-API env vars are gone from the library. If you were setting `datadog.service` / `datadog.env` / `datadog.version`, move them onto `commonLabels.tags.datadoghq.com/*` in your release values.

## [1.5.0] - 2026-05-11

### Changed

- **BREAKING:** Root-level `schedule`, `command`, `args`, and `job` keys are no longer supported. Declare every scheduled task through the `cronjobs:` map — one entry per CronJob, even when there is only one. `backoffLimit`/`ttlSecondsAfterFinished` move from the nested `job:` block onto the entry directly. Per-entry config inherits root `configMap.envFrom`, `volumes.*`, `commonEnvVars`, `extraEnv`, `resources`, and `image`.
- Updated to common library 1.7.0.

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

## [1.4.0] - 2026-05-05

### Added

- **`timeZone` value** — set `timeZone: "Europe/Zurich"` (or any IANA TZ) to render `spec.timeZone` on the CronJob, keeping schedules stable across DST transitions. Requires Kubernetes 1.27+.
- Updated to common library 1.6.0

## [1.3.2] - 2026-04-14

### Fixed

- Picks up `common` 1.5.2: `tags.datadoghq.com/env` label and `DD_ENV` env var are omitted when `datadog.env` is empty (no more namespace fallback). Set `datadog.env` explicitly (e.g. `dev-titan`).

## [1.3.1] - 2026-04-02

### Added

- `volumes.secret` support for mounting Kubernetes Secrets as volumes
- Updated to common library 1.5.1

## [1.3.0] - 2026-04-01

### Changed

- `env` changed from list to map format — merges with common defaults via Helm deep merge
- Added `extraEnv` list for `valueFrom`/`secretKeyRef` cases
- Updated to common library 1.5.0

## [1.2.0] - 2026-03-18

### Changed

- Replace `deploymentEnabled: false` with `workload.type: none` (common library 1.4.0)

## [1.0.0] - 2026-02-10

### Added

- Initial release of task chart for scheduled CronJob workloads
- Built on common library chart for shared functionality
- Includes CronJob and ServiceAccount
- Simplified values.yaml with sensible defaults for scheduled tasks
- Configurable schedule, concurrency policy, and history limits
- Job-level configuration: backoffLimit, ttlSecondsAfterFinished, completions, parallelism
- No HPA, PDB, service, or ingress (not applicable for scheduled tasks)
- Secure defaults for pod and container security contexts
- Default restartPolicy set to OnFailure for jobs
- Datadog Admission Controller pod label enabled by default
