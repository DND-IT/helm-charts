# Changelog

All notable changes to the karpenter-resources Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-06

### Added
- Full compatibility with Karpenter 1.6.0
- Enhanced JSON schema validation for Karpenter v1+ requirements
- Support for new metadataOptions fields (`httpEndpoint`, `httpProtocolIPv6`, `httpTokens`)
- Support for `associatePublicIPAddress` and `instanceStorePolicy` fields
- Improved amiSelectorTerms validation with support for all selector types (`alias`, `id`, `name`, `owner`, `tags`)
- **NEW**: Added comprehensive support for On-Demand Capacity Reservations (ODCRs) via `capacityReservationSelectorTerms`

### Changed
- **BREAKING**: `amiSelectorTerms` is now required when EC2NodeClass is enabled (Karpenter v1+ requirement)
- **BREAKING**: Updated Chart appVersion to 1.6.0 for Karpenter 1.6 compatibility
- Enhanced values.yaml with comprehensive documentation for all Karpenter 1.6 fields
- Updated JSON schema to enforce amiFamily enum values and required fields

### Removed
- **BREAKING**: Removed deprecated `instanceProfile` field - use `role` instead (Karpenter v1+ requirement)
- **BREAKING**: Removed deprecated `global.instanceProfileName` - use `global.role` instead

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
