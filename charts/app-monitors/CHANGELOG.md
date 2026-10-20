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
- Routing tags built from `team`, `env`, `app` and `repository`; render fails when any is missing
- Optional per-monitor `severity`, rendered as the `severity:` tag
- Optional per-monitor `priority` (1 to 5); not rendered when unset
- Monitor titles start with `[<env>]`
