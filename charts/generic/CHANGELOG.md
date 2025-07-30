# Changelog

All notable changes to the generic Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
