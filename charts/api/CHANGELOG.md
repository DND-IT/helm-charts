# Changelog

All notable changes to the api Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-10

### Added

- Initial release of api chart for internal API services
- Built on common library chart for shared functionality
- Includes Deployment, Service (enabled by default), optional Ingress, HPA, PDB, ServiceAccount
- Simplified values.yaml with sensible defaults for internal services
- Ingress disabled by default (internal services don't need external traffic)
- Service enabled by default for internal cluster communication
- Secure defaults for pod and container security contexts
- Support for topology spread constraints
- Health checks with liveness and readiness probes
