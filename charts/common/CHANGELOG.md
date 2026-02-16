# Changelog

All notable changes to the common Helm library chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
