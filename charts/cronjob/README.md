# cronjob

![Version: 0.11.0](https://img.shields.io/badge/Version-0.11.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A generic kubernetes cron job

## Usage

Reference the release of the chart you want to deploy in terraform

```hcl
resource "helm_release" "cronjob" {
  name       = "cronjob"
  repository = "https://dnd-it.github.io/helm-charts"
  chart      = "cronjob"

  values = [
    templatefile("values.yaml")
  ]
  set {
    name  = "foo"
    value = "bar"
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
| cronjob.backoffLimit | int | `3` |  |
| cronjob.concurrencyPolicy | string | `"Allow"` |  |
| cronjob.failedJobsHistoryLimit | int | `1` |  |
| cronjob.restartPolicy | string | `"Never"` |  |
| cronjob.schedule | string | `"0 0 * * *"` |  |
| cronjob.startingDeadlineSeconds | int | `120` |  |
| cronjob.successfulJobsHistoryLimit | int | `3` |  |
| cronjob.suspend | bool | `false` | If cronjob executions should be suspended. |
| cronjob.timeZone | string | `"Etc/UTC"` |  |
| cronjobName | string | `""` |  |
| env | object | `{}` |  |
| externalSecrets.annotations | object | `{}` |  |
| externalSecrets.clusterSecretStore | string | `"aws-secretsmanager"` |  |
| externalSecrets.refreshInterval | string | `"5m"` |  |
| externalSecrets.secretNames | list | `[]` |  |
| extraEnvFrom | list | `[]` |  |
| extraObjects | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image_pull_policy | string | `"IfNotPresent"` |  |
| image_repo | string | `"nginx"` |  |
| image_tag | string | `"stable"` |  |
| metadata.labels.datadog.env | string | `""` |  |
| metadata.labels.datadog.service | string | `""` |  |
| metadata.labels.datadog.version | string | `""` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| port | int | `80` |  |
| resources | object | `{}` |  |
| tolerations | list | `[]` |  |
