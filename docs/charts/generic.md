# Generic Chart

The generic chart is the most flexible chart in the repository. It supports all Kubernetes workload types and exposes every configuration option from the common library without opinionated defaults.

Use this chart when the wrapper charts (web, api, worker, task) don't fit your use case, or when you need full control over every setting.

## Features

- Deployment, StatefulSet, DaemonSet, Job, CronJob workloads
- Multiple deployments via `extraDeployments`
- Multiple services via `extraServices`
- Full Gateway API support (HTTPRoute, GRPCRoute, TCPRoute, TLSRoute, UDPRoute)
- AWS Load Balancer Controller v3 CRDs
- Init containers and native sidecar containers
- ConfigMap and Secret management with auto-reload
- External Secrets Operator integration
- HPA, VPA, and PDB
- RBAC with ServiceAccount
- NetworkPolicy
- Helm hooks (pre/post install/upgrade/delete)
- Persistent volumes (PVC, emptyDir, hostPath)
- Pod-level and container-level resources

## Basic Usage

```yaml
image:
  repository: my-registry/my-app
  tag: "1.0.0"

ports:
  - name: http
    containerPort: 8080

service:
  enabled: true

resources:
  requests:
    cpu: 100m
    memory: 128Mi
```

## Multiple Deployments

Deploy additional workloads alongside the main deployment:

```yaml
extraDeployments:
  worker:
    replicas: 2
    image:
      repository: my-registry/my-app
      tag: "1.0.0"
    command: ["python", "-m", "worker"]
    container:
      resources:
        requests:
          cpu: 200m
          memory: 256Mi
```

## Jobs and CronJobs

```yaml
# One-off jobs
jobs:
  migrate:
    image:
      repository: my-registry/my-app
      tag: "1.0.0"
    command: ["python", "-m", "migrate"]
    backoffLimit: 3

# Scheduled jobs
cronjobs:
  cleanup:
    schedule: "0 2 * * *"
    image:
      repository: my-registry/my-app
      tag: "1.0.0"
    command: ["python", "-m", "cleanup"]
```

## Helm Hooks

```yaml
hooks:
  enabled: true
  preUpgrade:
    - name: db-migrate
      image:
        repository: my-registry/my-app
        tag: "1.0.0"
      command: ["python", "-m", "migrate"]
      resources:
        limits:
          memory: "256Mi"
```

## All Values

See the [values reference](../reference/values.md) for the complete list of available configuration options.
