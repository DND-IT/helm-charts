# custom-resources

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Deploy custom resources via Helm

## Usage

define any custom resources in a file and use the `templatefile` function to include it in the values section of the helm release.
This allows you to apply custom resources in the same step as the custom resource definition.

eg. Karpenter Controller and Karpenter NodePools / EC2NodeClass can be appled without the need for
the kubectl provider

```hcl
resource "helm_release" "custom_resources" {
  name       = "custom-resources"
  repository = "https://dnd-it.github.io/helm-charts"
  chart      = "custom-resources"

  values = [
    templatefile("node-pool.yaml")
  ]
  set {
    name  = "spec.limits.cpu"
    value = "100"
  }
}
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <dai@tamedia.ch> |  |
