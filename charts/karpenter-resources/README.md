# karpenter-resources

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.2](https://img.shields.io/badge/AppVersion-1.3.2-informational?style=flat-square)

A Helm chart for Karpenter Custom Resources

## Usage

Reference the release of the chart you want to deploy in terraform

```hcl
resource "helm_release" "karpenter_resources" {
  name       = "karpenter-resources"
  repository = "https://dnd-it.github.io/helm-charts"
  chart      = "karpenter-resources"

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
| default.enabled | bool | `true` |  |
| default.role | string | `"foo"` |  |
| ec2NodeClasses.default.amiSelectorTerms[0].alias | string | `"bottlerocket@latest"` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].deviceName | string | `"/dev/xvda"` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.deleteOnTermination | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.encrypted | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.volumeSize | string | `"4Gi"` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.volumeType | string | `"gp3"` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].deviceName | string | `"/dev/xvdb"` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.deleteOnTermination | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.encrypted | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.volumeSize | string | `"20Gi"` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.volumeType | string | `"gp3"` |  |
| ec2NodeClasses.default.instanceProfile | string | `""` |  |
| ec2NodeClasses.default.metadataOptions.httpPutResponseHopLimit | int | `2` |  |
| ec2NodeClasses.default.role | string | `"ThisNeedsToBeReplaced"` |  |
| ec2NodeClasses.default.securityGroupSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.subnetSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.tags | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| global.eksDiscovery.clusterName | string | `""` |  |
| global.eksDiscovery.enabled | bool | `true` |  |
| global.eksDiscovery.ownershipValue | string | `"owned"` |  |
| global.instanceProfileName | string | `""` |  |
| global.roleName | string | `""` |  |
| nameOverride | string | `""` |  |
| nodePools.default.annotations | object | `{}` |  |
| nodePools.default.disruption.consolidateAfter | string | `"5m"` |  |
| nodePools.default.disruption.consolidationPolicy | string | `"WhenEmptyOrUnderutilized"` |  |
| nodePools.default.expireAfter | string | `"720h"` |  |
| nodePools.default.labels | object | `{}` |  |
| nodePools.default.limits.cpu | int | `100` |  |
| nodePools.default.limits.memory | string | `"400Gi"` |  |
| nodePools.default.nodeClassRef.group | string | `"karpenter.k8s.aws"` |  |
| nodePools.default.nodeClassRef.kind | string | `"EC2NodeClass"` |  |
| nodePools.default.nodeClassRef.name | string | `"default"` |  |
| nodePools.default.requirements[0].key | string | `"karpenter.k8s.aws/instance-category"` |  |
| nodePools.default.requirements[0].operator | string | `"In"` |  |
| nodePools.default.requirements[0].values[0] | string | `"c"` |  |
| nodePools.default.requirements[0].values[1] | string | `"m"` |  |
| nodePools.default.requirements[0].values[2] | string | `"r"` |  |
| nodePools.default.requirements[0].values[3] | string | `"t"` |  |
| nodePools.default.requirements[1].key | string | `"karpenter.k8s.aws/instance-cpu"` |  |
| nodePools.default.requirements[1].operator | string | `"In"` |  |
| nodePools.default.requirements[1].values[0] | string | `"2"` |  |
| nodePools.default.requirements[1].values[1] | string | `"4"` |  |
| nodePools.default.requirements[1].values[2] | string | `"8"` |  |
| nodePools.default.requirements[1].values[3] | string | `"16"` |  |
| nodePools.default.requirements[1].values[4] | string | `"32"` |  |
| nodePools.default.requirements[2].key | string | `"karpenter.k8s.aws/instance-hypervisor"` |  |
| nodePools.default.requirements[2].operator | string | `"In"` |  |
| nodePools.default.requirements[2].values[0] | string | `"nitro"` |  |
| nodePools.default.requirements[3].key | string | `"karpenter.k8s.aws/instance-memory"` |  |
| nodePools.default.requirements[3].operator | string | `"Gt"` |  |
| nodePools.default.requirements[3].values[0] | string | `"2048"` |  |
| nodePools.default.requirements[4].key | string | `"karpenter.sh/capacity-type"` |  |
| nodePools.default.requirements[4].operator | string | `"In"` |  |
| nodePools.default.requirements[4].values[0] | string | `"spot"` |  |
| nodePools.default.requirements[4].values[1] | string | `"on-demand"` |  |
| nodePools.default.requirements[5].key | string | `"karpenter.k8s.aws/instance-generation"` |  |
| nodePools.default.requirements[5].operator | string | `"Gt"` |  |
| nodePools.default.requirements[5].values[0] | string | `"2"` |  |
| nodePools.default.startupTaints | list | `[]` |  |
| nodePools.default.taints | list | `[]` |  |
