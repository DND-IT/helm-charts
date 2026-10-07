# Changelog

All notable changes to the app-monitors Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-07

### Added

- Initial release
- Workload monitors: pod restarts, OOMKilled, replicas not ready
- HPA at max replicas monitor
- SQS oldest message age and backlog monitors
- Routing tags built from `team`, `env` and `app`; render fails when any is missing
- Workload and HPA monitor titles start with `[<aws_account_alias> - <kube_cluster_name>]`; SQS monitor titles start with `[<env>]`
