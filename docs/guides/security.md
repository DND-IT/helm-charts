# Security Defaults

All charts ship with secure defaults following Kubernetes security best practices. No configuration needed - security is on by default.

## Pod Security Context

Applied to every pod:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  fsGroupChangePolicy: OnRootMismatch
  seccompProfile:
    type: RuntimeDefault
```

## Container Security Context

Applied to every container:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault
```

## Overriding Defaults

### Per-chart Override

Override security contexts in your values:

```yaml
# Override pod security context
pod:
  securityContext:
    runAsUser: 101      # nginx user
    runAsGroup: 101
    fsGroup: 101

# Override container security context
securityContext:
  runAsUser: 101
  readOnlyRootFilesystem: true
```

### Global Override

Override the defaults for all workloads in the chart:

```yaml
security:
  defaultPodSecurityContext:
    runAsNonRoot: true
    runAsUser: 65534    # nobody user
  defaultContainerSecurityContext:
    readOnlyRootFilesystem: false  # If your app needs to write
```

## Read-only Root Filesystem

The default `readOnlyRootFilesystem: true` means containers cannot write to their filesystem. For applications that need writable directories, use emptyDir volumes:

```yaml
volumes:
  emptyDir:
    tmp:
      mountPath: /tmp
      sizeLimit: 100Mi
    cache:
      mountPath: /var/cache/app
      sizeLimit: 200Mi
```

## Service Account

A dedicated ServiceAccount is created by default:

```yaml
serviceAccount:
  enabled: true                    # Created by default
  automountServiceAccountToken: true
  annotations:
    # For AWS IRSA:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789:role/MyRole"
```

## RBAC

Create Roles and RoleBindings for your service account:

```yaml
rbac:
  enabled: true
  type: Role    # or ClusterRole
  rules:
    - apiGroups: [""]
      resources: ["configmaps"]
      verbs: ["get", "list"]
```

## Network Policy

Restrict pod-to-pod communication:

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: gateway-system
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to: []
      ports:
        - protocol: TCP
          port: 443
```

## Pod Security Standards

Enable Kubernetes-native Pod Security Standards labels on the namespace:

```yaml
security:
  podSecurityStandards:
    enabled: true
    enforce: restricted
    audit: restricted
    warn: restricted
```
