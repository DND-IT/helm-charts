# karpenter-resources

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.0](https://img.shields.io/badge/AppVersion-1.6.0-informational?style=flat-square)

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
  eksDiscovery:
    enabled: true
    clusterName: my-cluster

nodePools:
  default:
    enabled: true
    # Requirements are a map keyed by a short alias. Narrowing one entry keeps
    # every other default (instance-hypervisor, capacity-type, ...) intact.
    requirements:
      instance-category:
        values: ["c"]
      instance-cpu:
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

### NodePool defaults and list-or-map fields

`nodePools.defaults` is a reserved key holding values that are deep-merged
**underneath every** NodePool. Per-pool values always win, and `defaults` never
renders a NodePool of its own -- so a custom pool needs to declare only what
makes it different:

```yaml
nodePools:
  defaults:
    expireAfter: "168h"          # applies to every pool below
  default:
    enabled: true
  production:
    enabled: true
    nodeClassRef:
      name: production           # everything else is inherited
```

`requirements`, `taints`, `startupTaints` and `disruption.budgets` accept
**either a list or a map keyed by a short alias**. The map form is the one to
reach for in an overlay: Helm deep-merges maps, so you can change a single
field of a single entry, whereas a list replaces the whole set.

```yaml
nodePools:
  default:
    enabled: true
    requirements:
      instance-cpu:
        values: ["8", "16"]      # narrowed; key and operator inherited
      instance-memory:
        enabled: false           # drop an inherited entry
      instance-family:           # add a new one
        key: karpenter.k8s.aws/instance-family
        operator: In
        values: ["c5", "c5d"]
```

Map entries are rendered in sorted alias order. Karpenter ANDs requirements
together and applies the most restrictive matching disruption budget, so order
carries no meaning.

To remove inherited entries, in order of preference:

1. set `enabled: false` on the individual entry;
2. use the **list** form to replace the whole set;
3. set the field to `[]` -- correct for `taints`, `startupTaints` and
   `disruption.budgets`; for `requirements` this renders a NodePool the
   Karpenter CRD rejects unless the pool supplies its own;
4. set `nodePools: {defaults: null}` to disable inheritance entirely.

`requirements: null` and `requirements: {}` do **not** work: Helm's value
coalescing deletes null-valued keys (indistinguishable from unset) and `{}`
merges without clearing. There is also no way to render a pool with no
`disruption` block at all once `defaults` supplies one -- use option 4.

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
| ec2NodeClasses.default.capacityReservationSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.enabled | bool | `false` |  |
| ec2NodeClasses.default.kubelet | object | `{}` |  |
| ec2NodeClasses.default.metadataOptions.httpEndpoint | string | `"enabled"` |  |
| ec2NodeClasses.default.metadataOptions.httpProtocolIPv6 | string | `"disabled"` |  |
| ec2NodeClasses.default.metadataOptions.httpPutResponseHopLimit | int | `2` |  |
| ec2NodeClasses.default.metadataOptions.httpTokens | string | `"required"` |  |
| ec2NodeClasses.default.role | string | `""` |  |
| ec2NodeClasses.default.securityGroupSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.subnetSelectorTerms | list | `[]` |  |
| ec2NodeClasses.default.tags | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| global.eksDiscovery.clusterName | string | `""` |  |
| global.eksDiscovery.enabled | bool | `false` |  |
| global.eksDiscovery.tags.securityGroups."karpenter.sh/discovery" | string | `""` |  |
| global.eksDiscovery.tags.subnets."karpenter.sh/discovery" | string | `""` |  |
| global.role | string | `""` |  |
| nameOverride | string | `""` |  |
| nodePools.default.enabled | bool | `false` |  |
| nodePools.default.nodeClassRef.name | string | `"default"` |  |
| nodePools.defaults | object | see below | Shared values deep-merged **underneath every** NodePool. Per-pool values always win. `defaults` is reserved and never renders a NodePool of its own; it must not set `enabled`. Set `nodePools.defaults: null` to opt out of inheritance entirely and get pre-1.1.0 behaviour. |
| nodePools.defaults.disruption.budgets | list/object | `[]` | Disruption budgets. Same list-or-map handling as `requirements`. Karpenter applies the most restrictive matching budget, so order does not matter. Set to `[]` for none. |
| nodePools.defaults.requirements | list/object | 6 entries keyed by alias, see values.yaml | Node requirements, ANDed together by Karpenter. Either a list (replaced wholesale by an overlay) or a map keyed by a short alias. The map form lets an overlay narrow ONE requirement without losing the others, e.g. `nodePools.defaults.requirements.instance-cpu.values`. Set `enabled: false` on an entry to drop it. Karpenter requires the field to be present, so `[]` renders an invalid NodePool unless the pool supplies its own. |
| nodePools.defaults.startupTaints | list/object | `[]` | Startup taints. Same list-or-map handling as `taints`. |
| nodePools.defaults.taints | list/object | `[]` | Node taints. Either a list (replaced wholesale by an overlay) or a map keyed by a short alias (deep-merged, so an overlay can change one entry; `enabled: false` drops an entry). Set to `[]` for none. |
