# Karpenter Resources Chart

Deploys [Karpenter](https://karpenter.sh/) NodePool and EC2NodeClass resources for automatic node provisioning on Amazon EKS.

## Resources Created

- **NodePool** - Defines scheduling constraints, limits, and disruption policies
- **EC2NodeClass** - Defines AWS-specific instance configuration (AMI, subnets, security groups)

## Basic Usage

```yaml
clusterName: my-eks-cluster

nodePool:
  requirements:
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand", "spot"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["m5.large", "m5.xlarge", "m6i.large", "m6i.xlarge"]

ec2NodeClass:
  amiFamily: AL2023
  role: KarpenterNodeRole-my-eks-cluster
```

## Full Example

```yaml
clusterName: my-eks-cluster

nodePool:
  requirements:
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["m6i.large", "m6i.xlarge", "m6i.2xlarge"]
  limits:
    cpu: "100"
    memory: 400Gi
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s

ec2NodeClass:
  amiFamily: AL2023
  role: KarpenterNodeRole-my-eks-cluster
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: my-eks-cluster
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: my-eks-cluster
  tags:
    Environment: production
```
