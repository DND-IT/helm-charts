# pgvector

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.8.0-pg17](https://img.shields.io/badge/AppVersion-0.8.0--pg17-informational?style=flat-square)

A simple PostgreSQL chart with pgvector extension for vector similarity search.
Designed for feature branch and development use cases.
Deploys a single-instance StatefulSet with persistent storage.

**Homepage:** <https://github.com/dnd-it/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <abc@abc.com> |  |

## Source Code

* <https://github.com/dnd-it/helm-charts>
* <https://github.com/pgvector/pgvector>

## Requirements

Kubernetes: `>=1.29.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| auth.database | string | `"app"` | Name of the application database to create |
| auth.existingSecret | string | `""` | Use an existing secret for passwords. Keys: postgres-password, password |
| auth.password | string | `""` | Password for the application user |
| auth.postgresPassword | string | `""` | Password for the postgres superuser. Required unless existingSecret is set. |
| auth.username | string | `"app"` | Name of the application user to create |
| commonAnnotations | object | `{}` | Common annotations to add to all resources |
| commonLabels | object | `{}` | Common labels to add to all resources |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` | Allow privilege escalation |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile |
| extraEnv | list | `[]` | Additional environment variables |
| extraVolumeMounts | list | `[]` | Additional volume mounts |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | Override the full resource name |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"pgvector/pgvector"` | Image repository |
| image.tag | string | `"0.8.0-pg17"` | Image tag (pgvector version + postgres version) |
| imagePullSecrets | list | `[]` | Image pull secrets |
| initdbScripts | object | `{}` | Map of script name to SQL content, executed alphabetically |
| livenessProbe.exec.command[0] | string | `"pg_isready"` |  |
| livenessProbe.exec.command[1] | string | `"-U"` |  |
| livenessProbe.exec.command[2] | string | `"postgres"` |  |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| metrics.enabled | bool | `false` | Enable postgres-exporter sidecar |
| metrics.image.pullPolicy | string | `"IfNotPresent"` | Exporter image pull policy |
| metrics.image.repository | string | `"prometheuscommunity/postgres-exporter"` | Exporter image repository |
| metrics.image.tag | string | `"v0.16.0"` | Exporter image tag |
| metrics.resources | object | `{}` | Exporter resource requests and limits |
| nameOverride | string | `""` | Override the chart name |
| networkPolicy.enabled | bool | `false` | Enable NetworkPolicy |
| networkPolicy.ingressRules | list | `[]` | Allowed ingress sources (empty allows all) |
| nodeSelector | object | `{}` | Node selector |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC |
| persistence.annotations | object | `{}` | Annotations for the PVC |
| persistence.enabled | bool | `true` | Enable persistent storage for PostgreSQL data |
| persistence.size | string | `"8Gi"` | Size of the persistent volume |
| persistence.storageClass | string | `""` | Storage class for the PVC (empty uses cluster default) |
| pgvector.createExtension | bool | `true` | Automatically create the vector extension in the application database |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget.enabled | bool | `false` | Enable PDB |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext.fsGroup | int | `999` | Filesystem group |
| podSecurityContext.runAsGroup | int | `999` | Run as group |
| podSecurityContext.runAsNonRoot | bool | `true` | Run as non-root |
| podSecurityContext.runAsUser | int | `999` | Run as user (999 = postgres) |
| postgresqlConfiguration | object | `{}` | Additional PostgreSQL configuration parameters (appended to postgresql.conf) |
| readinessProbe.exec.command[0] | string | `"pg_isready"` |  |
| readinessProbe.exec.command[1] | string | `"-U"` |  |
| readinessProbe.exec.command[2] | string | `"postgres"` |  |
| readinessProbe.failureThreshold | int | `6` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| resources | object | `{}` |  |
| service.annotations | object | `{}` | Additional service annotations |
| service.port | int | `5432` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Create a service account |
| serviceAccount.name | string | `""` | Service account name (generated if not set) |
| startupProbe.exec.command[0] | string | `"pg_isready"` |  |
| startupProbe.exec.command[1] | string | `"-U"` |  |
| startupProbe.exec.command[2] | string | `"postgres"` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `5` |  |
| startupProbe.periodSeconds | int | `5` |  |
| tolerations | list | `[]` | Tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
