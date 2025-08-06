# Changelog

All notable changes to the karpenter-resources Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2025-08-06

### Added
- Support for setting individual discovery tags for subnets and security groups through `global.eksDiscovery.tags`
- Ability to specify multiple tags for resource discovery beyond just `karpenter.sh/discovery`
- Automatic fallback to `clusterName` when `karpenter.sh/discovery` tag value is empty
- New CI test file `discovery-tags-values.yaml` demonstrating flexible tag configuration

### Changed
- Enhanced EC2NodeClass template to support the new discovery tags structure
- Discovery configuration now allows for more granular control over subnet and security group selection

### Removed
- Removed unused `eksOwnershipValue` variable from template

## [0.3.3] - Previous Release

_Note: This is the first tracked version in the changelog. For previous changes, please refer to git history._
