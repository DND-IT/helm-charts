# capella-scraper

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.1](https://img.shields.io/badge/AppVersion-1.0.1-informational?style=flat-square)

A Helm chart for deploying Capella Prometheus Scraper

**Homepage:** <https://github.com/DND-IT/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DND-IT |  | <https://github.com/DND-IT> |

## Source Code

* <https://github.com/DND-IT/helm-charts>

## Installation

### Add Helm repository

```shell
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update
```

### Install the chart

Using config from a file:

```bash
helm install --generate-name dnd-it/capella-scraper -f values.yaml
```

## Configuration

The following table lists the configurable parameters of the capella-scraper chart and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| capellaFQDN | string | `""` |  |
| image_pull_policy | string | `"Always"` |  |
| image_repo | string | `""` |  |
| image_tag | string | `"1.0.1"` |  |
| jobName | string | `""` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"1024Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| scrapePass | string | `""` |  |
| scrapeUser | string | `""` |  |
| service.port | int | `8080` |  |
| service.targetPort | int | `8080` |  |
| serviceAccountName | string | `"prometheus-operator-kube-p-operator"` |  |

## Examples

### Basic Usage

```yaml
# values.yaml
image_repo: "your-registry/capella-scraper"
image_tag: "1.0.1"

capellaFQDN: "cb.example.cloud.couchbase.com"
jobName: "feed-capella-production"
scrapeUser: "feed-admin"
scrapePass: "your-password"
```

## Terraform Migration

Example Terraform configuration to migrate from:

```hcl
resource "kubernetes_deployment" "feed-prom-capella-scraper" {
  # ... deployment configuration
}

resource "kubernetes_service" "feed-prom-capella-scraper-service" {
  # ... service configuration
}
```

To Helm:

```hcl
resource "helm_release" "capella_scraper" {
  name       = "capella-scraper"
  repository = "https://dnd-it.github.io/helm-charts"
  chart      = "capella-scraper"
  version    = "0.1.0"
  namespace  = "monitoring"

  values = [
    yamlencode({
      image_repo = var.capella_container_registry_url
      image_tag  = "1.0.1"

      capellaFQDN = var.capella_FQDN
      jobName     = "feed-capella-${var.environment}"
      scrapeUser  = var.capella_scrape_user
      scrapePass  = var.capella_scrape_pass
    })
  ]
}
```
