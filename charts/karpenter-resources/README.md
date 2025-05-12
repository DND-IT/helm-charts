# karpenter-resources

![Version: 0.3.2](https://img.shields.io/badge/Version-0.3.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.3](https://img.shields.io/badge/AppVersion-1.3.3-informational?style=flat-square)

A Helm chart for Karpenter Custom Resources

## Usage

### Plain Helm Install Example

To install the chart directly using Helm CLI:

```bash
# Add the repository
helm repo add dnd-it https://dnd-it.github.io/helm-charts
helm repo update

# Install the chart with custom values
helm install karpenter-resources dnd-it/karpenter-resources \
  --namespace kube-system \
  --set global.role=karpenter-node-role \
  --set global.eksDiscovery.clusterName=my-cluster \
  --set nodePools.default.enabled=true \
  --set nodePools.default.nodeClassRef.name=default \
  --set ec2NodeClasses.default.enabled=true \
  --set ec2NodeClasses.default.amiFamily=Bottlerocket
```

Alternatively, you can use a values file:

```bash
# Create a values.yaml file with your configuration
cat > values.yaml << EOF
global:
  role: karpenter-node-role
  instanceProfileName: karpenter-node-instance-profile

nodePools:
  default:
    enabled: true
    requirements:
      - key: "karpenter.k8s.aws/instance-category"
        operator: In
        values: ["c"]
      - key: "karpenter.k8s.aws/instance-cpu"
        operator: In
        values: ["8"]
    limits:
      cpu: 100
      memory: 400Gi

ec2NodeClasses:
  default:
    enabled: true
    amiFamily: Bottlerocket
    amiSelectorTerms:
      - alias: bottlerocket@latest
    blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 10Gi
          volumeType: gp3
          encrypted: true
          deleteOnTermination: true
EOF

# Install using the values file
helm install karpenter-resources dnd-it/karpenter-resources \
  --namespace karpenter \
  --create-namespace \
  -f values.yaml
```

### Terraform Example

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
    name  = "nodePools.default.enabled"
    value = "true"
  }
  set {
    name  = "ec2NodeClasses.default.enabled"
    value = "true"
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
| ec2NodeClasses.default.amiFamily | string | `"Bottlerocket"` |  |
| ec2NodeClasses.default.amiSelectorTerms[0].alias | string | `"bottlerocket@latest"` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].deviceName | string | `"/dev/xvda"` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.deleteOnTermination | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.encrypted | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.volumeSize | string | `"4Gi"` |  |
| ec2NodeClasses.default.blockDeviceMappings[0].ebs.volumeType | string | `"gp3"` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].deviceName | string | `"/dev/xvdb"` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.deleteOnTermination | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.encrypted | bool | `true` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.volumeSize | string | `"50Gi"` |  |
| ec2NodeClasses.default.blockDeviceMappings[1].ebs.volumeType | string | `"gp3"` |  |
| ec2NodeClasses.default.enabled | bool | `false` |  |
| ec2NodeClasses.default.instanceProfile | string | `""` |  |
| ec2NodeClasses.default.kubelet | object | `{}` |  |
| ec2NodeClasses.default.metadataOptions.httpPutResponseHopLimit | int | `2` |  |
| ec2NodeClasses.default.role | string | `""` |  |
| ec2NodeClasses.default.securityGroupSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.subnetSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.tags | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| global.eksDiscovery.clusterName | string | `""` |  |
| global.eksDiscovery.enabled | bool | `false` |  |
| global.instanceProfileName | string | `""` |  |
| global.role | string | `""` |  |
| nameOverride | string | `""` |  |
| nodePools.default.annotations | object | `{}` |  |
| nodePools.default.disruption.consolidateAfter | string | `"5m"` |  |
| nodePools.default.disruption.consolidationPolicy | string | `"WhenEmptyOrUnderutilized"` |  |
| nodePools.default.enabled | bool | `false` |  |
| nodePools.default.expireAfter | string | `"720h"` |  |
| nodePools.default.labels | object | `{}` |  |
| nodePools.default.limits.cpu | int | `1000` |  |
| nodePools.default.limits.memory | string | `"4000Gi"` |  |
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
| nodePools.default.requirements[1].values[0] | string | `"4"` |  |
| nodePools.default.requirements[1].values[1] | string | `"8"` |  |
| nodePools.default.requirements[1].values[2] | string | `"16"` |  |
| nodePools.default.requirements[1].values[3] | string | `"32"` |  |
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
