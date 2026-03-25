# TODO — Helm Charts

Audit conducted 2026-03-25 across all DND-IT org repos consuming these charts.

## Bugs

- [ ] **`timeZone` missing from task chart's singular CronJob template**
  - `charts/common/templates/classes/workloads/_cronjob.tpl` does not pass through `timeZone`
  - The plural `cronjobs` template supports it, but the task chart's dedicated CronJob does not
  - FUW cronjobs use `timeZone: "Europe/Zurich"` and will break on migration
  - Fix: add `timeZone` field to the singular CronJob template, same as the plural one

- [ ] **TargetGroupConfiguration healthCheckPort defaults to `8080`**
  - Web chart defaults `healthCheckPort: "8080"` and `healthCheckPath: "/readyz"`
  - 7 titan-services use different container ports (80, 3001, 3003, 3004, 3005) and none override the health check port
  - Services also use varied health check paths (`/health`, `/actuator/health`, `/health-check/*`) but don't override `healthCheckPath`
  - If TargetGroupConfiguration renders (depends on `gateway.k8s.aws/v1beta1` API), ALB health checks would target wrong port/path
  - Fix: consider deriving healthCheckPort from `service.ports[0].containerPort` and healthCheckPath from `readinessProbe.httpGet.path`

- [ ] **`hpa.targetCPUUtilizationPercentage` undocumented**
  - The HPA template supports this shorthand and many titan-services use it in prod
  - Not declared in `charts/common/values.yaml` (only `metrics: []` exists)
  - Schema validation could flag it as unknown
  - Fix: add `targetCPUUtilizationPercentage` to common values.yaml with a comment, and regenerate schema

## UX Improvements

- [ ] **Default `/tmp` emptyDir volume**
  - Every single service across all repos mounts a `/tmp` emptyDir (100Mi-500Mi)
  - This is required because `readOnlyRootFilesystem: true` is the default
  - Consider adding a default `/tmp` emptyDir in common so users don't have to repeat this boilerplate

- [ ] **Worker chart lacks common defaults for HTTP workers**
  - fission-demo's go-service had to manually add ports, service, all three probes, and nodeSelector
  - Workers that serve HTTP for health checks and metrics need significant boilerplate
  - Consider: add a `worker.http` preset or at minimum document the recommended pattern

- [ ] **`configMap.envFrom` not defaulted in worker/task charts**
  - Web chart defaults `configMap.envFrom: true`, but worker and task do not
  - Every consumer manually enables it — consider making it a common default

- [ ] **Gateway API parentRefs boilerplate**
  - Every web-chart service configures the exact same gateway pattern: `parentRefs` to `default` in `gateway-system`, `sectionName: https`
  - Consider better defaults in the web chart to reduce per-service boilerplate

## Adoption & Migration

### Current chart adoption (as of 2026-03-25)

| Chart | Status | Repos | Services |
|-------|--------|-------|----------|
| `webapp` | **deprecated** | 12 | ~15 |
| `cronjob` | **deprecated** | 3 | ~7 |
| `web` | current | 2 (titan-services, fission-demo) | 13 |
| `task` | current | 1 (titan-services) | 2 |
| `worker` | current | 1 (fission-demo) | 1 |
| `generic` | current | 4 (fission, fission-demo, discovery-social-media, fission-templates) | 3+ |

### Repos still on deprecated charts

**webapp (v1.10.0–v1.13.1):**
- fuw (analyse, backoffice)
- disco-backstage (api)
- disco-astro
- disco-legacy-redirector, disco-fuw-legacy-redirector, bilan-legacy-redirector
- discovery-ai-tools (api, frontend, celery-worker, celery-beat)
- discovery-gazette (webapp, celery-beat, celery-worker)
- discovery-data-extraction (backend, frontend)
- fuw-invest, fuw-special-work
- mini-me-feeds
- fission-argocd (template), github-workflows (test)

**cronjob (v0.7.0–v0.11.0):**
- fuw (4 cron jobs via aliases)
- disco-backstage (3 cron jobs via aliases)
- fuw-factsheets

### Migration blockers / friction

- [ ] **Flat `env` map → list format**
  - All webapp/cronjob users use `env: {KEY: value}` (flat map)
  - New charts use `env: [{name: KEY, value: value}]` (list)
  - Migration path: use `configMap.data` as the simpler alternative for flat env vars
  - Document this in a migration guide

- [ ] **`aws_iam_role_arn` convenience shorthand removed**
  - webapp auto-created a ServiceAccount with the IAM role annotation
  - New charts require `serviceAccount.annotations."eks.amazonaws.com/role-arn"`
  - Consider adding a convenience value or document the migration

- [ ] **Multiple CronJob aliases pattern**
  - FUW and disco-backstage use Chart.yaml dependency aliases to create multiple cronjob instances
  - New approach uses `cronjobs` map in common/generic, which is cleaner but different
  - Needs migration documentation

- [ ] **`externalSecrets.secretNames` shorthand removed**
  - webapp/cronjob had a simple list-based interface (`secretNames: [key1, key2]`)
  - New chart's map-based approach is more flexible but more verbose
  - Document the equivalent configuration

- [ ] **Worker pattern for celery**
  - discovery-ai-tools and discovery-gazette abuse webapp for celery workers by disabling service/probes
  - The `worker` chart exists for this but needs migration documentation

- [ ] **Write a migration guide** (`docs/guides/migration.md` exists but may need updating)
  - webapp → web (value path changes, env format, IAM role, probes)
  - cronjob → task (aliases → cronjobs map, env format, timeZone)
  - webapp-as-worker → worker (disable service/probes pattern)

## Features actively used across consumers

For reference — features confirmed in use across the org:

- Gateway API HTTPRoute (all web services in titan + fission)
- ExternalSecrets with AWS Secrets Manager + ClusterSecretStore
- ExtraObjects for PodIdentityAssociation (EKS Pod Identity)
- ConfigMap with envFrom (every service)
- HPA with targetCPUUtilizationPercentage shorthand (all prod web services)
- PDB with minAvailable: 1 (all prod)
- EmptyDir volumes for /tmp (every service)
- Security context overrides for root/nginx (4 services)
- InitContainers for DB migrations (2 services)
- ExtraDeployments/ExtraServices (gotthard MCP sidecars)
- Stakater Reloader annotations (8+ services)
- CommonLabels for team + environment tagging
- Pod labels for Datadog USM
- Lifecycle hooks (preStop sleep for graceful shutdown)

## Not using DND-IT charts

- **CMS** — uses its own custom `base` library chart (not a migration candidate)
- **fission-templates** — generates `generic` chart dependencies for all new projects (already on current charts)
