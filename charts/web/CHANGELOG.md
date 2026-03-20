# Changelog

All notable changes to the web Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
