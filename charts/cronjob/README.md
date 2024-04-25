# cron-helm-chart

Contains the generic helm chart that run kubernetes cron job. It is used by Prometheus & Disco projects

## Usage

To deploy a k8s cronjob simply create a helm value file and refer it in the terraform code.
Here it is an example with a value file accepting some parameters set from the terraform code

### Helm Value File Example

File `example.yaml`

```yaml
image_repo: curlimages/curl
image_tag: ${image_tag}
metadata:
  labels:
    datadog:
      env: ${datadog_env}
      service: ${service_name}
      version: v${image_tag}
port: 3200
service:
  name: ${service_name}
env:
  URL: ${url_env}
cronjob:
  schedule: ${cronjob_schedule}
```

### Terraform File Example

File `example.tf`

```hcl
resource "helm_release" "trigger_url" {
  name             = "trigger-a-google-search"
  chart            = "https://github.com/DND-IT/cron-helm-chart/archive/v1.1.0.tar.gz"
  namespace        = lower(var.branch)
  create_namespace = true
  max_history      = 10

  values = [
    templatefile("${path.module}/example.yaml", {
      service_name     = "search"
      image_tag        = "8.2.1"
      datadog_env      = "disco-sbx"
      url_env          = "https://www.google.com"
      cronjob_schedule = "*/10 * * * *" # Every 10 minutes
    }),
    yamlencode({
      args = ["https://www.google.com"]
    })
  ]
}
```
