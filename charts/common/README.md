# common

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

A Helm library chart containing shared templates and helpers for Kubernetes workloads.
Provides common functionality for naming, labels, security contexts, containers, pods, and volumes.
Designed to be used as a dependency by application charts (web, api, worker, cronjob).

## Overview

The **common** chart is a Helm library chart that provides shared templates and helper functions used by other charts in this repository. It is **not meant to be installed directly**.

## Use Cases

This library chart is used as a dependency by:

- **generic** - Full-featured application chart
- **api** - Internal API services
- **web** - External-facing web applications
- **worker** - Background processing workloads
- **task** - Scheduled CronJob workloads

## Structure

```
templates/
├── lib/                           # Core helper functions
│   ├── _names.tpl                 # Name generation (fullname, chart, etc.)
│   ├── _labels.tpl                # Label generation (common, selector)
│   ├── _template.tpl              # Template utilities (tplValue)
│   ├── _image.tpl                 # Image name resolution with registry support
│   ├── _security.tpl              # Security context helpers
│   ├── _env.tpl                   # Environment variable helpers
│   ├── _container.tpl             # Container spec generation
│   ├── _volumes.tpl               # Volume and mount helpers
│   └── _pod.tpl                   # Pod template generation
│
└── classes/                       # Kubernetes resource templates
    ├── config/
    │   ├── _configmap.tpl         # ConfigMap resources
    │   ├── _secret.tpl            # Secret resources
    │   └── _externalsecret.tpl    # External Secrets Operator
    │
    ├── workloads/
    │   ├── _deployment.tpl        # Deployment resources
    │   ├── _cronjob.tpl           # CronJob resources
    │   └── _job.tpl               # Job resources
    │
    ├── networking/
    │   ├── _service.tpl           # Service resources
    │   ├── _ingress.tpl           # Ingress resources
    │   ├── _networkpolicy.tpl     # NetworkPolicy resources
    │   ├── _targetgroupbinding.tpl # AWS TargetGroupBinding
    │   └── gateway/
    │       ├── _httproute.tpl     # Gateway API HTTPRoute
    │       ├── _tcproute.tpl      # Gateway API TCPRoute
    │       └── _referencegrant.tpl # Gateway API ReferenceGrant
    │
    ├── scaling/
    │   ├── _hpa.tpl               # HorizontalPodAutoscaler
    │   └── _pdb.tpl               # PodDisruptionBudget
    │
    ├── rbac/
    │   ├── _serviceaccount.tpl    # ServiceAccount resources
    │   └── _rbac.tpl              # Role/ClusterRole and bindings
    │
    ├── storage/
    │   └── _pvc.tpl               # PersistentVolumeClaim
    │
    └── _extraobjects.tpl          # Arbitrary custom resources
```

## Usage as Dependency

Add the common chart as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: "1.x.x"
    repository: "file://../common"  # or your chart repository URL
```

Then use the templates in your chart:

```yaml
# templates/deployment.yaml
{{- include "common.deployment" . }}

# templates/service.yaml
{{- include "common.service" . }}
```

## Available Templates

### Library Helpers (lib/)

| Template | Description |
|----------|-------------|
| `common.name` | Chart name |
| `common.fullname` | Full release name |
| `common.chart` | Chart name and version |
| `common.labels` | Standard Kubernetes labels |
| `common.selectorLabels` | Selector labels for pods |
| `common.image` | Image name with registry resolution |
| `common.containerImage` | Container image helper |
| `common.podSecurityContext` | Pod security context |
| `common.containerSecurityContext` | Container security context |
| `common.envVars` | Environment variables |
| `common.container` | Full container spec |
| `common.volumes` | Volume definitions |
| `common.volumeMounts` | Volume mount definitions |
| `common.podTemplate` | Complete pod template |

### Resource Classes (classes/)

| Template | Description |
|----------|-------------|
| `common.configmap` | ConfigMap resource |
| `common.extraConfigMaps` | Additional ConfigMaps |
| `common.secret` | Secret resource |
| `common.extraSecrets` | Additional Secrets |
| `common.externalSecrets` | External Secrets |
| `common.deployment` | Deployment resource |
| `common.extraDeployments` | Additional Deployments |
| `common.cronjob` | CronJob resource |
| `common.jobs` | Job resources |
| `common.service` | Service resource |
| `common.extraServices` | Additional Services |
| `common.ingress` | Ingress resource |
| `common.extraIngresses` | Additional Ingresses |
| `common.hpa` | HorizontalPodAutoscaler |
| `common.pdb` | PodDisruptionBudget |
| `common.serviceaccount` | ServiceAccount |
| `common.rbac` | Role and RoleBinding |
| `common.extraRbac` | Additional RBAC resources |
| `common.pvc` | PersistentVolumeClaims |
| `common.networkPolicy` | NetworkPolicy |
| `common.httpRoute` | Gateway API HTTPRoute |
| `common.tcpRoute` | Gateway API TCPRoute |
| `common.referenceGrant` | Gateway API ReferenceGrant |
| `common.targetGroupBinding` | AWS TargetGroupBinding |
| `common.extraObjects` | Arbitrary Kubernetes resources |

## Global Registry Support

The library supports `global.image.registry` for centralized registry configuration:

```yaml
global:
  image:
    registry: my-private-registry.io

image:
  repository: myapp  # Results in: my-private-registry.io/myapp:tag
  tag: v1.0.0
```

Registry resolution order:
1. Explicit `image.registry` on the resource
2. Repository already contains registry (e.g., `ghcr.io/org/app`) - preserved
3. `global.image.registry` fallback
4. No registry (use default)

**Homepage:** <https://github.com/dnd-it/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DAI | <abc@abc.com> |  |

## Source Code

* <https://github.com/dnd-it/helm-charts>

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.1.0](https://github.com/norwoodj/helm-docs/releases/v1.1.0)
