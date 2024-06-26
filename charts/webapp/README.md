# webapp

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A generic kubernetes application

## Usage

Reference the release of the chart you want to deploy in terraform

```hcl
resource "helm_release" "app" {
  name       = "app"
  repository = "https://dnd-it.github.io/helm-charts"
  chart      = "webapp"

  values = [
    templatefile("values.yaml")
  ]
  set {
    name  = "service.name"
    value = "my-custom-service-name"
  }
}
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <dai@tamedia.ch> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| command | list | `[]` |  |
| env | object | `{}` |  |
| externalSecrets.clusterSecretStore | string | `"aws-secretsmanager"` |  |
| externalSecrets.refreshInterval | string | `"5m"` |  |
| externalSecrets.secretNames | list | `[]` |  |
| image_pull_policy | string | `"IfNotPresent"` |  |
| image_repo | string | `"nginx"` |  |
| image_tag | string | `"latest"` |  |
| ingress.annotations | string | `nil` |  |
| ingress.className | string | `nil` |  |
| ingress.hosts | list | `[]` |  |
| ingress.paths[0] | string | `"/"` |  |
| ingress.tls | bool | `false` |  |
| metadata.deploymentAnnotations | object | `{}` |  |
| metadata.hpaAnnotations | object | `{}` |  |
| metadata.labels.datadog.env | string | `""` |  |
| metadata.labels.datadog.service | string | `""` |  |
| metadata.labels.datadog.version | string | `""` |  |
| metadata.podAnnotations | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| port | int | `80` |  |
| probe.liveness | string | `"/"` |  |
| probe.livenessInitialDelaySeconds | int | `0` |  |
| probe.livenessPeriodSeconds | int | `10` |  |
| probe.livenessTimeoutSeconds | int | `2` |  |
| probe.readiness | string | `"/"` |  |
| probe.readinessFailureThreshold | int | `2` |  |
| probe.readinessInitialDelaySeconds | int | `0` |  |
| probe.readinessPeriodSeconds | int | `5` |  |
| probe.readinessTimeoutSeconds | int | `2` |  |
| probe.startup | string | `nil` |  |
| probe.startupHttpHeaders | string | `nil` |  |
| probe.startupTimeoutSeconds | int | `1` |  |
| resources | object | `{}` |  |
| scale.cpuThresholdPercentage | int | `100` |  |
| scale.enabled | bool | `true` |  |
| scale.maxReplicas | int | `10` |  |
| scale.memoryThresholdPercentage | int | `-1` |  |
| scale.minAvailable | string | `"50%"` |  |
| scale.minReplicas | int | `1` |  |
| service.annotations | string | `nil` |  |
| service.enabled | bool | `true` |  |
| service.name | string | `nil` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints[0] | object | `{"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone","whenUnsatisfiable":"ScheduleAnyway"}` | Enable pod [Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/). If no constraints are defined, the cluster default is used. - topologyKey: topology.kubernetes.io/zone   maxSkew: 5   whenUnsatisfiable: ScheduleAnyway - topologyKey: kubernetes.io/hostname   maxSkew: 3   whenUnsatisfiable: ScheduleAnyway |
| topologySpreadConstraints[1].maxSkew | int | `1` |  |
| topologySpreadConstraints[1].topologyKey | string | `"kubernetes.io/hostname"` |  |
| topologySpreadConstraints[1].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| update.maxSurge | string | `"25%"` |  |
| update.maxUnavailable | string | `"0%"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
