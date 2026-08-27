# Karpenter Resources Chart

Deploys [Karpenter](https://karpenter.sh/) NodePool and EC2NodeClass resources for automatic node provisioning on Amazon EKS.

## Resources Created

- **NodePool** - one per key under `nodePools`. Defines scheduling constraints, limits, and disruption policies.
- **EC2NodeClass** - one per key under `ec2NodeClasses`. Defines AWS-specific instance configuration (AMI, subnets, security groups, IAM role).

Both are opt-in: a pool or node class renders only when its `enabled` is `true`.

## Basic Usage

```yaml
global:
  # IAM role Karpenter assigns to the nodes it launches
  role: KarpenterNodeRole-my-eks-cluster
  eksDiscovery:
    # Discover subnets and security groups by the standard EKS tags
    enabled: true
    clusterName: my-eks-cluster

nodePools:
  default:
    enabled: true

ec2NodeClasses:
  default:
    enabled: true
    amiFamily: AL2023
    amiSelectorTerms:
      - alias: al2023@latest
```

That is enough for a working setup: the chart ships sensible NodePool defaults
(nitro hypervisor, 4-32 vCPU, spot and on-demand, 720h node expiry,
consolidation when empty or underutilized, 1000 vCPU / 4000Gi limits).

## NodePool defaults

`nodePools.defaults` is a **reserved key**. Everything under it is deep-merged
*underneath* every NodePool, and it never renders a NodePool of its own. A
custom pool therefore declares only what makes it different:

```yaml
nodePools:
  defaults:
    expireAfter: "168h"          # applies to every pool below
    limits:
      cpu: 2000
      memory: 8000Gi
  default:
    enabled: true
  production:
    enabled: true
    nodeClassRef:
      name: production           # everything else is inherited
```

Because `defaults` is reserved, it is not a usable pool name. Setting
`nodePools.defaults.enabled` fails the template with an explanatory error rather
than silently rendering a pool named `defaults`.

### Merge precedence

Outermost wins, and there are three layers:

1. **Your `-f overlay.yaml`**, deep-merged over the chart's `values.yaml` by
   Helm's value coalescing *before* any template runs.
2. **`nodePools.defaults`**, used as the merge destination.
3. **The pool's own values**, used as the merge source — so they win over
   `defaults`.

This is the same `mustMergeOverwrite` idiom the common library uses; see
[values deep merge](../architecture/values-deep-merge.md).

## List-or-map fields

`requirements`, `taints`, `startupTaints` and `disruption.budgets` accept
**either a list or a map keyed by a short alias**.

The distinction matters because Helm deep-merges maps but **replaces lists
wholesale**. With a list, narrowing one requirement discards every other one —
including safety-relevant defaults like `instance-hypervisor: nitro`. With a
map, you change one field of one entry and the siblings survive:

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

The list form still works and still replaces the whole set, so existing values
files keep their current behaviour:

```yaml
nodePools:
  default:
    enabled: true
    requirements:                # replaces all six defaults
      - key: karpenter.k8s.aws/instance-cpu
        operator: In
        values: ["8"]
```

Map entries are rendered in **sorted alias order**, so output is deterministic.
Karpenter ANDs requirements together and applies the most restrictive matching
disruption budget, so the order carries no meaning.

`enabled` on a map entry is a chart-level control only — it is stripped and
never appears in the rendered manifest.

### Removing inherited entries

In order of preference:

1. Set `enabled: false` on the individual map entry.
2. Use the **list** form to replace the whole set.
3. Set the field to `[]`. Correct for `taints`, `startupTaints` and
   `disruption.budgets`, which are all optional. For `requirements` this renders
   a NodePool the Karpenter CRD **rejects**, since `spec.template.spec` requires
   `requirements` — only do it when the pool supplies its own.
4. Set `nodePools: {defaults: null}` to disable inheritance entirely.

Two things that do **not** work: `requirements: null` (Helm's coalescing deletes
null-valued keys, making it indistinguishable from unset) and `requirements: {}`
(an empty map merges without clearing anything). There is likewise no clean way
to render a pool with no `disruption` block once `defaults` supplies one — use
option 4.

## Full Example

```yaml
global:
  role: KarpenterNodeRole-my-eks-cluster
  eksDiscovery:
    enabled: true
    clusterName: my-eks-cluster
    tags:
      subnets:
        karpenter.sh/discovery: my-eks-cluster
        tier: private
      securityGroups:
        karpenter.sh/discovery: my-eks-cluster

nodePools:
  defaults:
    requirements:
      instance-cpu:
        values: ["8", "16", "32"]
    disruption:
      consolidationPolicy: WhenEmptyOrUnderutilized
      consolidateAfter: 30s
      budgets:
        empty-and-drifted:
          nodes: "20%"
          reasons: ["Empty", "Drifted"]

  default:
    enabled: true

  batch:
    enabled: true
    weight: 10
    nodeClassRef:
      name: batch
    requirements:
      capacity-type:
        values: ["spot"]
    taints:
      batch-only:
        key: example.com/batch
        value: "true"
        effect: NoSchedule
    limits:
      cpu: "100"
      memory: 400Gi

ec2NodeClasses:
  default:
    enabled: true
    amiFamily: AL2023
    amiSelectorTerms:
      - alias: al2023@latest
    tags:
      Environment: production
  batch:
    enabled: true
    amiFamily: Bottlerocket
    amiSelectorTerms:
      - alias: bottlerocket@latest
```

When `global.eksDiscovery.enabled` is `true`, `subnetSelectorTerms` and
`securityGroupSelectorTerms` are generated from `global.eksDiscovery.tags`,
falling back to `karpenter.sh/discovery: <clusterName>`. Set them explicitly on
an EC2NodeClass to override.

## All Values

See the [chart README](https://github.com/dnd-it/helm-charts/tree/main/charts/karpenter-resources)
for the generated reference of every available value.
