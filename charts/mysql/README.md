# mysql

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying MySQL 8.0 to Kubernetes using a StatefulSet.
Includes headless Service, PVC via volumeClaimTemplates, ConfigMap for custom my.cnf,
Secret for credentials, and health checks.
Designed for stateful MySQL deployments with persistent storage.

**Homepage:** <https://github.com/dnd-it/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <abc@abc.com> |  |

## Source Code

* <https://github.com/dnd-it/helm-charts>

## Requirements

Kubernetes: `>=1.32.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 1.x.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configMap.data."custom.cnf" | string | `"[mysqld]\ndefault-authentication-plugin=caching_sha2_password\nmax_connections=200\ninnodb_buffer_pool_size=256M\n"` |  |
| configMap.enabled | bool | `true` |  |
| configMap.mountPath | string | `"/etc/mysql/conf.d"` |  |
| hpa.enabled | bool | `false` |  |
| image.repository | string | `"mysql"` |  |
| image.tag | string | `"8.0"` |  |
| livenessProbe.exec.command[0] | string | `"mysqladmin"` |  |
| livenessProbe.exec.command[1] | string | `"ping"` |  |
| livenessProbe.exec.command[2] | string | `"-h"` |  |
| livenessProbe.exec.command[3] | string | `"localhost"` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| pod.terminationGracePeriodSeconds | int | `60` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| ports[0].containerPort | int | `3306` |  |
| ports[0].name | string | `"mysql"` |  |
| ports[0].protocol | string | `"TCP"` |  |
| readinessProbe.exec.command[0] | string | `"mysqladmin"` |  |
| readinessProbe.exec.command[1] | string | `"ping"` |  |
| readinessProbe.exec.command[2] | string | `"-h"` |  |
| readinessProbe.exec.command[3] | string | `"localhost"` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| resources.limits.memory | string | `"1Gi"` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| scheduling.topologySpreadConstraints | list | `[]` |  |
| secret.enabled | bool | `true` |  |
| secret.envFrom | bool | `true` |  |
| secret.stringData.MYSQL_ROOT_PASSWORD | string | `""` |  |
| security.defaultContainerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| security.defaultContainerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| security.defaultContainerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| security.defaultContainerSecurityContext.runAsNonRoot | bool | `true` |  |
| security.defaultContainerSecurityContext.runAsUser | int | `999` |  |
| security.defaultContainerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| security.defaultPodSecurityContext.fsGroup | int | `999` |  |
| security.defaultPodSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| security.defaultPodSecurityContext.runAsGroup | int | `999` |  |
| security.defaultPodSecurityContext.runAsNonRoot | bool | `true` |  |
| security.defaultPodSecurityContext.runAsUser | int | `999` |  |
| security.defaultPodSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| service.enabled | bool | `true` |  |
| service.publishNotReadyAddresses | bool | `true` |  |
| service.type | string | `"ClusterIP"` |  |
| startupProbe.exec.command[0] | string | `"mysqladmin"` |  |
| startupProbe.exec.command[1] | string | `"ping"` |  |
| startupProbe.exec.command[2] | string | `"-h"` |  |
| startupProbe.exec.command[3] | string | `"localhost"` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `5` |  |
| startupProbe.timeoutSeconds | int | `3` |  |
| statefulset.persistentVolumeClaimRetentionPolicy.whenDeleted | string | `"Retain"` |  |
| statefulset.persistentVolumeClaimRetentionPolicy.whenScaled | string | `"Retain"` |  |
| statefulset.podManagementPolicy | string | `"OrderedReady"` |  |
| statefulset.updateStrategy.type | string | `"RollingUpdate"` |  |
| statefulset.volumeClaimTemplates | object | `{}` |  |
| volumes.emptyDir.mysql-run.mountPath | string | `"/var/run/mysqld"` |  |
| volumes.emptyDir.tmp.mountPath | string | `"/tmp"` |  |
| volumes.persistent.data.accessModes[0] | string | `"ReadWriteOnce"` |  |
| volumes.persistent.data.mountPath | string | `"/var/lib/mysql"` |  |
| volumes.persistent.data.size | string | `"10Gi"` |  |
| workload.type | string | `"deployment"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
