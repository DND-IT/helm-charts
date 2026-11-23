# Changelog

All notable changes to the app-monitors Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-11-23

### Added

All off by default.

- Workload monitor `crashLoopBackOff`: containers waiting with reason CrashLoopBackOff
- Workload monitor `imagePullBackOff`: containers waiting with reason ImagePullBackOff
- Workload monitor `cpuThrottling`: CPU throttling of a deployment's containers
- Workload monitor `memoryOverRequest`: memory usage above the request, in percent
- Workload monitor `replicasAvailableLow`: available replicas as a percentage of desired
- HPA monitor `hpaReplicasSurge`: desired replicas against the previous window, in percent
- PDB monitor `pdbNoDisruptionsAllowed`: a PodDisruptionBudget with no pod to spare

## [0.1.0] - 2026-10-07

### Added

- Initial release
- Workload monitors: pod restarts, OOMKilled, replicas not ready
- HPA at max replicas monitor
- SQS oldest message age and backlog monitors
- Routing tags built from `team`, `env`, `app` and `repository`; render fails when any is missing
- Optional per-monitor `severity`, rendered as the `severity:` tag
- Optional per-monitor `priority` (1 to 5); not rendered when unset
- Monitor titles start with `[<env>]`
