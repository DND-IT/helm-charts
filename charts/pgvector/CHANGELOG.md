# Changelog

## 0.1.0

- Initial release
- Single-instance PostgreSQL StatefulSet with pgvector extension
- Automatic `CREATE EXTENSION vector` via initdb script
- Persistent storage with VolumeClaimTemplate
- Optional postgres-exporter metrics sidecar with ServiceMonitor
- Network Policy and Pod Disruption Budget support
- Container security hardening by default
