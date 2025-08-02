# capella-scraper

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.1](https://img.shields.io/badge/AppVersion-1.0.1-informational?style=flat-square)

A Helm chart for deploying Capella Prometheus Scraper

## Usage

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
      image_tag  = var.capella_image_tag

      capellaFQDN = var.capella_FQDN
      jobName     = "feed-capella-${var.environment}"
      scrapeUser  = var.capella_scrape_user
      scrapePass  = var.capella_scrape_pass

      serviceAccountName = "prometheus-operator-kube-p-operator"  # Must exist in namespace
    })
  ]
}
```
**Homepage:** <https://github.com/DND-IT/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <dai@tamedia.ch> |  |

## Source Code

* <https://github.com/DND-IT/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| capellaFQDN | string | `""` |  |
| image_pull_policy | string | `"Always"` |  |
| image_repo | string | `""` |  |
| image_tag | string | `""` |  |
| jobName | string | `""` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"1024Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| scrapePass | string | `""` |  |
| scrapeUser | string | `""` |  |
| service.port | int | `8080` |  |
| service.targetPort | int | `8080` |  |
| serviceAccountName | string | `""` |  |
