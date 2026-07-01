# Changelog

All notable changes to the mysql Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-07-01

### Added

- Picks up `common` 1.11.0: `extraObjects` now accepts a **map keyed by name** in addition to the existing list form, so an overlay (additional `-f` values file) can deep-merge and override individual fields of an entry instead of replacing the whole list. Map entries can be disabled with `enabled: false`. The default is now `null` so either form merges without a Helm coalesce warning. The list form is unchanged and backward compatible.

## [0.2.3] - 2026-07-01

### Changed

- Picks up `common` 1.10.0, which adds a `values.schema.json` to the library so the `common:` values block is now schema-validated.

## [0.2.2] - 2026-04-14

### Fixed

- Picks up `common` 1.5.2: `tags.datadoghq.com/env` label and `DD_ENV` env var are omitted when `datadog.env` is empty (no more namespace fallback). Set `datadog.env` explicitly (e.g. `dev-titan`).

## [0.2.1] - 2026-04-02

### Added

- `volumes.secret` support for mounting Kubernetes Secrets as volumes
- Updated to common library 1.5.1

## [0.2.0] - 2026-04-01

### Changed

- `env` changed from list to map format — merges with common defaults via Helm deep merge
- Added `extraEnv` list for `valueFrom`/`secretKeyRef` cases
- Updated to common library 1.5.0

## [0.1.0] - 2026-03-18

### Added

- Initial release of MySQL chart
- Dual workload mode: Deployment (default, for feature branches) or StatefulSet (for persistent environments)
- Deployment mode uses standalone PVC for data storage
- StatefulSet mode uses volumeClaimTemplates with per-replica storage
- ConfigMap for custom my.cnf configuration
- Secret for MySQL root password
- Health checks using mysqladmin ping
- Security context defaults for MySQL user (UID 999)
- Sensible resource defaults
