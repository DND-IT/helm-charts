# Changelog

All notable changes to the generic Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.11.0] - 2026-04-01

### Changed

- `env` changed from list to map format (`env: {LOG_LEVEL: info}`) — merges with common defaults via Helm deep merge
- Added `extraEnv` list for `valueFrom`/`secretKeyRef` cases
- `port` value as single source of truth for container port, service targetPort, and healthCheckPort
- Updated to common library 1.5.0

## [0.10.0] - 2026-03-18

### Changed

- Replace `deploymentEnabled` with `workload.type` (deployment, statefulset, daemonset, none)
- Updated to common library 1.4.0

## [0.9.1] - 2026-03-17

### Fixed

- Fixed invalid `TargetGroupConfiguration` health check field names in test fixtures (`healthCheckTimeoutSeconds` → removed, `healthCheckIntervalSeconds` → `healthCheckInterval`)

## [0.8.0] - 2026-02-10

### Changed

- Migrated to use common library chart as a dependency
- All templates now use `common.*` helpers directly (removed `_lib/` wrapper files)
- No breaking changes to existing values or template outputs

### Added

- Dependency on `common` library chart (1.x.x)

### Removed

- Removed `templates/_lib/` directory (helpers now provided by common library)

## [0.7.1] - 2026-02-06

### Fixed

- Fixed cronjob templates failing when `image` block is not specified, now defaults to empty dict and inherits from main `image` config

## [0.7.0] - 2026-02-05

### Added

- Added `global.registry` support to prepend a default container registry to all images
  - Follows standard Helm `global` convention for parent-to-subchart value passing
  - Registry precedence (highest to lowest): per-image registry → `image.registry` → `global.registry`
  - Applies to main deployment, init containers, sidecar containers, extra deployments, jobs, cronjobs, and hooks
  - String images already containing a registry (detected by `.` or `:` in first path segment) are not modified

## [0.6.0] - 2026-02-04

### Fixed

- Fixed `fullnameOverride` not being applied to `app.kubernetes.io/name` label in selector labels
- Fixed environment variables in `extraDeployments` not processing Helm template syntax (e.g., `{{ .Release.Name }}`)
- Fixed `extraDeployments` not respecting the `enabled: false` flag
- Fixed ingress backend to use named port reference instead of port number for better flexibility
- Fixed initContainers, extraContainers, and sidecarContainers to support image.registry override
- Added registry inheritance for init/extra/sidecar containers when image.registry is not explicitly set
- Added support for Helm template syntax in container image strings (e.g., `"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"`)
- Fixed service selectors to use `app.kubernetes.io/component` label for proper pod targeting:
  - Main deployment and service now use `app.kubernetes.io/component: main`
  - extraDeployments use `app.kubernetes.io/component: <name>` (e.g., `worker`, `mcp-argocd`)
  - extraServices automatically use matching component selector when a corresponding extraDeployment exists
  - This prevents services from accidentally selecting pods from other deployments

### Added

- Container images now support template evaluation using `tpl` function for dynamic image composition
- Service now defaults to top-level `ports` configuration when `service.ports` is not specified
- Support for `port` field in top-level ports to specify different service port from containerPort
- Template evaluation support for `commonLabels` and `commonAnnotations` (e.g., `app.kubernetes.io/version: "{{ .Values.image.tag }}"`)
- New `generic.tplYaml` helper for template evaluation in YAML dictionaries

### Changed

- Changed `service.ports` default from port 80 to empty array to enable automatic port detection from container ports
- Switched CI test images from Docker Hub to public mirrors (`public.ecr.aws`, `registry.k8s.io`) to avoid rate limits

## [0.1.0] - 2025-11-19

Preparing for prod release

### Changed

- Reworked most of the chart to put deployment spec into the root of the values.yaml


## [0.0.3] - 2025-08-01

### Added

- Support for commonLabels and commonAnnotations to replace global.labels and global.annotations
- Support for extraEnvFrom to allow additional environment sources while preserving automatic envFrom behavior
- Support for extraTargetGroupBindings
- Unified pod template (generic.podTemplate) that handles both main and extra deployments
- Support for envFrom on external secrets to automatically load all secret keys as environment variables

### Changed

- Replaced global.labels and global.annotations with commonLabels and commonAnnotations
- Enhanced generic.labels and generic.annotations helpers to accept dict parameters for merging additional labels/annotations
- Merged podTemplate and deploymentPodTemplate into a single unified template (generic.podTemplate) for better maintainability
- The generic.envFrom template now includes automatic configMap/secret references plus extraEnvFrom sources
- Moved all templates from templates/core/ to templates/ root directory for simpler structure
- External secrets now use the key name as the default secret name (instead of prefixing with fullname)

### Removed

- Removed generic.deploymentPodTemplate template (merged into generic.podTemplate)

### Fixed

- Fixed issue with extraObjects not being rendered correctly
- Fixed envFrom not being included in main deployment when using automatic configMap/secret envFrom

## [0.0.2] - 2025-07-29

### Removed

- Workload logic removed from generic chart

## [0.0.1] - 2025-07-01

### Added

- Initial release
- Support for all commonly used Kubernetes resources
- Comprehensive security defaults
- AWS ALB ingress support
