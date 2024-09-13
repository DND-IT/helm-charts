# webapp

![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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

## Upgrading

This section lists major and breaking changes of each Helm Chart version.

<details>
<summary>1.0.0</summary>

- Ingress resource are now created when `ingress.enabled` is set to `true`. ingress.hosts has no effect.
- Service name removed from values.yaml. Service name defaults to release name.
- Deployment pod port removed from values.yaml. Pod port defaults to service target port.

```
ingress:
  enabled: true
  hosts:
    - host: foo.bar
      paths:
        - /
```
</details>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <dai@tamedia.ch> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| aws_iam_role_arn | string | `""` |  |
| command | list | `[]` |  |
| env | object | `{}` |  |
| externalSecrets.clusterSecretStore | string | `"aws-secretsmanager"` |  |
| externalSecrets.refreshInterval | string | `"5m"` |  |
| externalSecrets.secretNames | list | `[]` |  |
| image_pull_policy | string | `"IfNotPresent"` |  |
| image_repo | string | `"nginx"` |  |
| image_tag | string | `"latest"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts | list | `[]` |  |
| ingress.paths[0] | string | `"/"` |  |
| ingress.tls | bool | `false` |  |
| metadata.deploymentAnnotations | object | `{}` |  |
| metadata.hpaAnnotations | object | `{}` |  |
| metadata.labels.datadog.env | string | `""` |  |
| metadata.labels.datadog.service | string | `""` |  |
| metadata.labels.datadog.version | string | `""` |  |
| metadata.podAnnotations."fluentbit.io/exclude" | string | `"true"` | Exclude or include pods logs from fluentbit collection |
| nodeSelector | object | `{}` |  |
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
| replicas | int | `1` |  |
| resources | object | `{}` |  |
| scale.cpuThresholdPercentage | int | `100` |  |
| scale.enabled | bool | `true` |  |
| scale.maxReplicas | int | `10` |  |
| scale.memoryThresholdPercentage | int | `-1` |  |
| scale.minAvailable | string | `"50%"` |  |
| scale.minReplicas | int | `1` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.port | int | `80` |  |
| service.portName | string | `"http"` |  |
| service.targetPort | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| targetGroupBinding.annotations | object | `{}` |  |
| targetGroupBinding.enabled | bool | `false` |  |
| targetGroupBinding.targetGroupARN | string | `""` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints[0] | object | `{"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone","whenUnsatisfiable":"ScheduleAnyway"}` | Enable pod [Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/). If no constraints are defined, the cluster default is used. - topologyKey: topology.kubernetes.io/zone   maxSkew: 5   whenUnsatisfiable: ScheduleAnyway - topologyKey: kubernetes.io/hostname   maxSkew: 3   whenUnsatisfiable: ScheduleAnyway |
| topologySpreadConstraints[1].maxSkew | int | `1` |  |
| topologySpreadConstraints[1].topologyKey | string | `"kubernetes.io/hostname"` |  |
| topologySpreadConstraints[1].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| update.maxSurge | string | `"25%"` |  |
| update.maxUnavailable | string | `"0%"` |  |
