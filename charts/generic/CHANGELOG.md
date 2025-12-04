# Changelog

All notable changes to the generic Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

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
