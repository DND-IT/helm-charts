# Migrating from Deprecated Charts

The `webapp` and `cronjob` charts are deprecated. Use `web` and `task` instead.

## webapp to web

### Key Differences

| Feature | webapp (old) | web (new) |
|---------|-------------|-----------|
| Library | Standalone templates | Common library |
| Ingress | ALB Ingress with annotations | Gateway API (HTTPRoute + AWS LBC CRDs) |
| Security | Manual configuration | Secure by default |
| Datadog | Manual labels | Automatic unified service tagging |
| Env vars | Manual | Common env vars (TZ, PORT, DD_*, etc.) |
| Resources | Container-level | Pod-level (K8s 1.32+) |

### Migration Steps

1. **Update Chart.yaml dependency**:

    ```yaml
    # Old
    dependencies:
      - name: webapp
        version: "x.x.x"

    # New
    dependencies:
      - name: web
        version: "1.x.x"
        repository: "oci://ghcr.io/dnd-it/helm-charts"
    ```

2. **Update Ingress to Gateway API**:

    ```yaml
    # Old (webapp)
    ingress:
      enabled: true
      annotations:
        alb.ingress.kubernetes.io/scheme: internet-facing
        alb.ingress.kubernetes.io/target-type: ip
      hosts:
        - host: myapp.example.com
          paths:
            - path: /
              pathType: Prefix

    # New (web)
    gateway:
      httpRoute:
        enabled: true
        parentRefs:
          - name: public-gateway
            namespace: gateway-system
        hostnames:
          - myapp.example.com
        rules:
          - matches:
              - path:
                  type: PathPrefix
                  value: /
            backendRefs:
              - name: my-web-app
                port: 80
      targetGroupConfiguration:
        enabled: true
        defaultConfiguration:
          targetType: ip
          healthCheckConfig:
            healthCheckPath: /readyz
            healthCheckPort: "8080"
      loadBalancerConfiguration:
        enabled: true
        scheme: internet-facing
    ```

3. **Remove manual security contexts** (now defaults):

    ```yaml
    # Remove these - they're now defaults:
    # pod:
    #   securityContext:
    #     runAsNonRoot: true
    #     runAsUser: 1000
    # securityContext:
    #   readOnlyRootFilesystem: true
    #   capabilities:
    #     drop: [ALL]
    ```

4. **Remove manual Datadog labels** (now automatic):

    ```yaml
    # Remove these - they're now automatic:
    # pod:
    #   labels:
    #     admission.datadoghq.com/enabled: "true"
    #     tags.datadoghq.com/service: my-app
    ```

---

## cronjob to task

### Key Differences

| Feature | cronjob (old) | task (new) |
|---------|--------------|------------|
| Library | Standalone templates | Common library |
| Security | Manual configuration | Secure by default |
| Resources | Container-level | Pod-level |
| Defaults | Minimal | Opinionated (concurrency, history, TTL) |

### Migration Steps

1. **Update Chart.yaml dependency**:

    ```yaml
    dependencies:
      - name: task
        version: "1.x.x"
        repository: "oci://ghcr.io/dnd-it/helm-charts"
    ```

2. **Map values**:

    ```yaml
    # Old (cronjob)
    schedule: "0 * * * *"
    image:
      repository: my-app
      tag: "1.0.0"

    # New (task) - same structure, more defaults included
    schedule: "0 * * * *"
    image:
      repository: my-app
      tag: "1.0.0"
    # concurrencyPolicy, history limits, job config all have defaults now
    ```
