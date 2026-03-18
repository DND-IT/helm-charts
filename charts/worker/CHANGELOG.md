# Changelog

All notable changes to the worker Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-03-18

### Changed

- Updated to common library 1.4.0 (`deploymentEnabled` replaced by `workload.type`)

## [1.0.0] - 2026-02-10

### Added

- Initial release of worker chart for background processing workloads
- Built on common library chart for shared functionality
- Includes Deployment, optional Service, HPA, PDB, ServiceAccount
- Simplified values.yaml with sensible defaults for worker processes
- Service disabled by default (workers typically don't expose ports)
- No ingress template (workers don't need external traffic)
- Optional health checks (not required for background workers)
- Secure defaults for pod and container security contexts
- Support for topology spread constraints
- Datadog Admission Controller pod label enabled by default
