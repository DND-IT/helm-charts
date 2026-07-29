# Changelog

All notable changes to the karpenter-resources Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-29

### Added
- New reserved `nodePools.defaults` key: values declared there are deep-merged **underneath every** NodePool, so a custom pool only has to declare what makes it different. Per-pool values always win, and `defaults` never renders a NodePool of its own.
- `requirements`, `taints`, `startupTaints` and `disruption.budgets` now accept **either a list or a map keyed by a short alias**. The map form is deep-merged by Helm, so an overlay can change one field of one entry; setting `enabled: false` on a map entry drops it.
- New CI fixture `ci/nodepool-defaults-values.yaml` and test suite `tests/nodepool_defaults_test.yaml`.

### Fixed
- Overriding a single requirement no longer silently drops the others. Previously `requirements` was a list, and Helm replaces lists wholesale, so narrowing e.g. `instance-cpu` also discarded safety-relevant defaults such as `instance-hypervisor: nitro` and `capacity-type`. Use the map form to avoid this.
- A NodePool with neither `labels` nor `annotations` emitted a childless `spec.template.metadata:`, which YAML parses as null and the Karpenter CRD rejects with `at '/spec/template/metadata': got null, want object`. The block is now omitted entirely when empty.

### Changed
- **Requirements from the map form are emitted in alphabetical alias order.** Existing installs that rely on the shipped defaults will see a one-time GitOps diff with no semantic change (Karpenter ANDs requirements together).
- **Custom pools now inherit `nodePools.defaults`**, which changes their rendered spec (they gain `expireAfter`, `disruption` and `limits` unless they set their own). Set `nodePools: {defaults: null}` to restore the previous behaviour.
- **`defaults` is reserved and can no longer be used as a NodePool name.** A `nodePools.defaults.enabled` key now fails the template with an explanatory message.
- The shipped defaults moved from `nodePools.default` to `nodePools.defaults`; `nodePools.default` now only carries `enabled` and `nodeClassRef.name`. Keeping them in both places would have made a leftover per-pool value permanently shadow anything set under `defaults`.
- `taints` and `startupTaints` defaults changed from `[]` to null, so supplying either form at that path no longer logs a `destination for ... is a table` coalesce warning.

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
