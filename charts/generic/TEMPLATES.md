# Template Organization

This directory contains Helm templates organized by functionality for better maintainability and discoverability.

## Folder Structure

### `_lib/` - Template Libraries
Reusable template helpers and shared functionality:
- `_helpers.tpl` - Core helper functions (names, labels, selectors)
- `_container.tpl` - Container specification templates
- `_pod.tpl` - Pod template with full Kubernetes features
- `_security.tpl` - Security context helpers
- `_volumes.tpl` - Volume and persistence helpers
- `_env.tpl` - Environment variable helpers
- `_workload.tpl` - Workload type routing logic

### `core/` - Core Kubernetes Resources
Essential Kubernetes workload and storage resources:
- `deployment.yaml` - Deployment workloads
- `statefulset.yaml` - StatefulSet workloads
- `daemonset.yaml` - DaemonSet workloads
- `job.yaml` - Job workloads
- `cronjob.yaml` - CronJob workloads
- `service.yaml` - Service definitions
- `configmap.yaml` - ConfigMap resources
- `secret.yaml` - Secret resources
- `pvc.yaml` - PersistentVolumeClaim resources

### `networking/` - Network Resources
Networking, traffic routing, and Gateway API resources:
- `ingress.yaml` - Traditional Ingress resources
- `networkpolicy.yaml` - Network policies for traffic control
- `gateway/` - Gateway API resources:
  - `gateway.yaml` - Gateway definitions
  - `gatewayclass.yaml` - GatewayClass resources
  - `httproute.yaml` - HTTP routing rules
  - `tcproute.yaml` - TCP routing rules
  - `referencegrant.yaml` - Cross-namespace access grants

### `autoscaling/` - Scaling Resources
Horizontal and vertical scaling resources:
- `hpa.yaml` - HorizontalPodAutoscaler
- `vpa.yaml` - VerticalPodAutoscaler

### `security/` - Security & RBAC
Security, access control, and policy resources:
- `serviceaccount.yaml` - Service account definitions
- `rbac.yaml` - Role, ClusterRole, and bindings
- `pdb.yaml` - PodDisruptionBudget for availability
- `pod-security-policy.yaml` - Pod Security Standards enforcement

### `monitoring/` - Observability Resources
Monitoring and observability integrations:
- `prometheus/` - Prometheus Operator resources:
  - `podmonitor.yaml` - PodMonitor for pod metrics
  - `prometheusrule.yaml` - Prometheus alerting rules
  - `servicemonitor.yaml` - ServiceMonitor for service metrics
- `datadog/` - Datadog integrations:
  - `datadogagent.yaml` - DatadogAgent resources (v2alpha1)
  - `datadogmonitor.yaml` - DatadogMonitor resources (v1alpha1)
  - `datadogslo.yaml` - DatadogSLO resources (v1alpha1)
  - `datadogmetric.yaml` - DatadogMetric resources (v1alpha1)
  - `datadogdashboard.yaml` - DatadogDashboard resources (v1alpha1)

### `lifecycle/` - Lifecycle Management
Helm hooks and lifecycle management:
- `hooks.yaml` - Pre/post install/upgrade/delete hooks

### `misc/` - Miscellaneous
Other resources and utilities:
- `extraobjects.yaml` - User-defined extra Kubernetes objects
- `NOTES.txt` - Post-installation notes and instructions

### `tests/` - Unit Tests
Organized unit tests matching the template structure:
- `core/` - Tests for core resources
- `networking/` - Tests for networking resources
- `monitoring/` - Tests for monitoring resources
- `lifecycle/` - Tests for lifecycle management
- Root level tests for helpers and cross-cutting concerns

## Benefits of This Organization

1. **Better Discoverability**: Related templates are grouped together
2. **Easier Maintenance**: Changes to specific features are isolated
3. **Clear Separation of Concerns**: Each folder has a specific purpose
4. **Scalable Structure**: Easy to add new integrations in appropriate folders
5. **Intuitive Navigation**: Developers can quickly find relevant templates
6. **Organized Testing**: Tests mirror the template structure

## Usage

The folder structure is transparent to Helm - all templates are processed normally. The organization only affects:
- Developer experience when browsing templates
- Maintenance and debugging workflows
- Source comments in rendered resources (e.g., `# Source: generic/templates/core/deployment.yaml`)

## Adding New Templates

When adding new templates:
1. **Core Kubernetes resources** → `core/`
2. **Networking features** → `networking/` (or `networking/gateway/` for Gateway API)
3. **Monitoring integrations** → `monitoring/prometheus/` or `monitoring/datadog/`
4. **Security features** → `security/`
5. **Scaling features** → `autoscaling/`
6. **Lifecycle hooks** → `lifecycle/`
7. **Vendor-specific resources** → Create new vendor folders under appropriate categories
8. **Shared helpers** → `_lib/`

Always add corresponding unit tests in the matching `tests/` subfolder.
