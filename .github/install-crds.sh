#!/bin/bash
# Install Required CRDs for Helm Charts

KARPENTER_VERSION="v1.3.2"
kubectl create -f https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.sh_nodepools.yaml
kubectl create -f https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml
