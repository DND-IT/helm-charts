# Changelog

All notable changes to the mysql Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
