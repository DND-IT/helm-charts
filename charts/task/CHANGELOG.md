# Changelog

All notable changes to the task Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
