# webapp

![Version: 1.8.0](https://img.shields.io/badge/Version-1.8.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| extraEnvFrom | list | `[]` |  |
| extraObjects | list | `[]` |  |
| image_pull_policy | string | `"IfNotPresent"` |  |
| image_repo | string | `"nginx"` |  |
| image_tag | string | `"latest"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts | list | `[]` |  |
| ingress.paths[0] | string | `"/"` |  |
| ingress.tls | bool | `false` |  |
| initContainer.args | list | `[]` |  |
| initContainer.command | list | `[]` |  |
| initContainer.enabled | bool | `false` |  |
| initContainer.image | string | `""` |  |
| initContainer.image_tag | string | `""` |  |
| initContainer.name | string | `""` |  |
| metadata.deploymentAnnotations | object | `{}` |  |
| metadata.hpaAnnotations | object | `{}` |  |
| metadata.labels.datadog.env | string | `""` |  |
| metadata.labels.datadog.service | string | `""` |  |
| metadata.labels.datadog.version | string | `""` |  |
| metadata.podAnnotations | object | `{}` |  |
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
| topologySpreadConstraints.enabled | bool | `true` |  |
| topologySpreadConstraints.maxSkew | int | `1` | Enable pod [Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/). |
| topologySpreadConstraints.topologyKeys | list | `["topology.kubernetes.io/zone","kubernetes.io/hostname"]` | The key of node labels. See https://kubernetes.io/docs/reference/kubernetes-api/labels-annotations-taints/ All the labels will be considered to try to find the best match |
| topologySpreadConstraints.whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| update.maxSurge | string | `"25%"` |  |
| update.maxUnavailable | string | `"0%"` |  |
