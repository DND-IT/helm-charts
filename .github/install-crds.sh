#!/bin/bash
# Install Required CRDs for Helm Charts
set -euo pipefail

# Karpenter CRDs
KARPENTER_VERSION="v1.3.2"
kubectl create -f https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.sh_nodepools.yaml
kubectl create -f https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml

# Gateway API CRDs (standard channel includes HTTPRoute, GRPCRoute, ReferenceGrant)
# renovate: datasource=github-releases depName=gateway-api packageName=kubernetes-sigs/gateway-api
GATEWAY_API_VERSION="v1.2.1"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml
# Experimental channel adds TCPRoute, TLSRoute, UDPRoute
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/experimental-install.yaml

# AWS Load Balancer Controller v3 CRDs (TargetGroupConfiguration, LoadBalancerConfiguration, ListenerRuleConfiguration)
# renovate: datasource=github-releases depName=aws-load-balancer-controller packageName=kubernetes-sigs/aws-load-balancer-controller
AWS_LBC_VERSION="v3.1.0"
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${AWS_LBC_VERSION}/config/crd/bases/gateway.k8s.aws_targetgroupconfigurations.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${AWS_LBC_VERSION}/config/crd/bases/gateway.k8s.aws_loadbalancerconfigurations.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${AWS_LBC_VERSION}/config/crd/bases/gateway.k8s.aws_listenerruleconfigurations.yaml
