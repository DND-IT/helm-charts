{{/*
Primary loader for the common chart.
Renders all Kubernetes resources based on values configuration.
Usage: {{- include "common.loader.generate" . }}
*/}}

{{/*
Helper to render a resource with a YAML document separator.
Outputs "---\n<content>" only if content is non-empty.
If content already starts with "---", it is used as-is (multi-document output).
*/}}
{{- define "common.loader.renderResource" -}}
  {{- $content := . | trim -}}
  {{- if $content -}}
    {{- if hasPrefix "---" $content }}
{{ $content }}
    {{- else }}
---
{{ $content }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "common.loader.generate" -}}
  {{- /* Merge common library defaults with chart values */ -}}
  {{- include "common.values.init" . -}}

  {{- /* Validation */ -}}
  {{- include "common.validateValues" . -}}

  {{- /* Security */ -}}
  {{- include "common.loader.renderResource" (include "common.serviceaccount" .) -}}
  {{- include "common.loader.renderResource" (include "common.rbac" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraRbac" .) -}}
  {{- include "common.loader.renderResource" (include "common.podSecurityStandards" .) -}}

  {{- /* Config */ -}}
  {{- include "common.loader.renderResource" (include "common.configmap" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraConfigMaps" .) -}}
  {{- include "common.loader.renderResource" (include "common.secret" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraSecrets" .) -}}
  {{- include "common.loader.renderResource" (include "common.externalSecrets" .) -}}

  {{- /* Storage */ -}}
  {{- include "common.loader.renderResource" (include "common.pvc" .) -}}

  {{- /* Workloads */ -}}
  {{- include "common.loader.renderResource" (include "common.deployment" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraDeployments" .) -}}
  {{- include "common.loader.renderResource" (include "common.jobs" .) -}}
  {{- include "common.loader.renderResource" (include "common.cronjob" .) -}}
  {{- include "common.loader.renderResource" (include "common.cronjobs" .) -}}
  {{- include "common.loader.renderResource" (include "common.hooks" .) -}}

  {{- /* Networking */ -}}
  {{- include "common.loader.renderResource" (include "common.service" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraServices" .) -}}
  {{- include "common.loader.renderResource" (include "common.ingress" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraIngresses" .) -}}
  {{- include "common.loader.renderResource" (include "common.networkPolicy" .) -}}
  {{- include "common.loader.renderResource" (include "common.targetGroupBinding" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraTargetGroupBindings" .) -}}

  {{- /* Gateway API */ -}}
  {{- include "common.loader.renderResource" (include "common.httpRoute" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraHttpRoutes" .) -}}
  {{- include "common.loader.renderResource" (include "common.grpcRoute" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraGrpcRoutes" .) -}}
  {{- include "common.loader.renderResource" (include "common.tcpRoute" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraTcpRoutes" .) -}}
  {{- include "common.loader.renderResource" (include "common.tlsRoute" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraTlsRoutes" .) -}}
  {{- include "common.loader.renderResource" (include "common.udpRoute" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraUdpRoutes" .) -}}
  {{- include "common.loader.renderResource" (include "common.referenceGrant" .) -}}
  {{- include "common.loader.renderResource" (include "common.extraReferenceGrants" .) -}}
  {{- include "common.loader.renderResource" (include "common.targetGroupConfiguration" .) -}}
  {{- include "common.loader.renderResource" (include "common.loadBalancerConfiguration" .) -}}
  {{- include "common.loader.renderResource" (include "common.listenerRuleConfiguration" .) -}}

  {{- /* Scaling */ -}}
  {{- include "common.loader.renderResource" (include "common.hpa" .) -}}
  {{- include "common.loader.renderResource" (include "common.pdb" .) -}}
  {{- include "common.loader.renderResource" (include "common.vpa" .) -}}

  {{- /* Extra */ -}}
  {{- include "common.loader.renderResource" (include "common.extraObjects" .) -}}
{{- end -}}
