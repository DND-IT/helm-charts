# Changelog

All notable changes to the common Helm library chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-03-17

### Added

- Commented-out examples in `values.yaml` for all major configuration sections: volumes, extraDeployments, cronjobs, jobs, extraServices, extraIngresses, rbac, extraConfigMaps, extraSecrets, externalSecrets, hpa, vpa, networkPolicy, all Gateway API routes, targetGroupBinding, hooks, and extraObjects

### Fixed

- Fixed invalid TargetGroupConfiguration health check field names in commented examples (`healthCheckIntervalSeconds` → `healthCheckInterval`)

## [1.2.0] - 2026-03-13

### Changed

- **Refactored workload templates to use composition hierarchy.** CronJob, Job, and Hook templates now delegate to `common.podTemplate` and `common.container` instead of reimplementing pod/container specs inline. This eliminates ~520 lines of duplicated code and ensures all workload types automatically inherit pod features (hostAliases, dnsPolicy, priorityClassName, topologySpreadConstraints, sidecar containers, etc.) and consistent security context defaults.
- **Extracted Gateway API shared helpers.** Created `common.gatewayParentRefs`, `common.gatewayBackendRef`, and `common.gatewayFilters` helpers to deduplicate parentRef, backendRef, and filter rendering across all 5 route types (HTTPRoute, GRPCRoute, TCPRoute, TLSRoute, UDPRoute).

### Added

- `common.jobSpec` helper for shared Job spec fields (completions, parallelism, backoffLimit, activeDeadlineSeconds, ttlSecondsAfterFinished, completionMode, suspend, podFailurePolicy)
- `common.gatewayParentRefs` helper for rendering parentRef list items across all route types
- `common.gatewayBackendRef` helper for rendering backendRef fields across all route types
- `common.gatewayFilters` helper for rendering filter lists (HTTPRoute and GRPCRoute)
- `defaultRestartPolicy` parameter on `common.podTemplate` for caller-specified defaults
- `mainContainer` parameter on `common.container` for main container behavior (envFrom, volumeMounts, commonEnvVars, service port fallback)
- `containerName` parameter on `common.container` for explicit container name override

## [1.0.1] - 2026-02-20

### Fixed

- `common.tplYaml`: Use `toYaml` for annotation/label values to properly quote numeric-looking strings (fixes kubeconform validation errors for Ingress annotations)

## [1.0.0] - 2026-02-10

### Added

- Initial release of common library chart
- Extracted shared helpers from generic chart:
  - `_names.tpl`: common.name, common.fullname, common.chart, common.namespace, common.serviceAccountName, common.configMapName, common.secretName, common.pvcName
  - `_labels.tpl`: common.labels, common.selectorLabels, common.annotations, common.podSecurityStandardsLabels
  - `_template.tpl`: common.tplValue, common.tplYaml, common.apiVersion
  - `_image.tpl`: common.image, common.resolveStringImage, common.containerImage
  - `_security.tpl`: common.podSecurityContext, common.containerSecurityContext, common.securityAnnotations, common.networkPolicySelector
  - `_env.tpl`: common.envVars, common.commonEnvVars, common.envFrom
  - `_container.tpl`: common.container, common.sidecarContainer
  - `_volumes.tpl`: common.volumes, common.volumeMounts
  - `_pod.tpl`: common.podTemplate, common.podAnnotations, common.topologySpreadConstraints, common.servicePort, common.serviceTargetPort, common.servicePortName, common.validateValues
- Secure defaults for pod and container security contexts
- Support for global.registry override
