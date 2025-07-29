{{/*
Pod security context with secure defaults
*/}}
{{- define "generic.podSecurityContext" -}}
{{- $securityContext := .securityContext | default dict -}}
{{- $defaults := .defaults | default dict -}}
{{- if not (hasKey $securityContext "runAsNonRoot") }}
runAsNonRoot: {{ $defaults.runAsNonRoot | default true }}
{{- else if $securityContext.runAsNonRoot }}
runAsNonRoot: {{ $securityContext.runAsNonRoot }}
{{- end }}
{{- if not (hasKey $securityContext "runAsUser") }}
runAsUser: {{ $defaults.runAsUser | default 1000 }}
{{- else if $securityContext.runAsUser }}
runAsUser: {{ $securityContext.runAsUser }}
{{- end }}
{{- if not (hasKey $securityContext "runAsGroup") }}
runAsGroup: {{ $defaults.runAsGroup | default 1000 }}
{{- else if $securityContext.runAsGroup }}
runAsGroup: {{ $securityContext.runAsGroup }}
{{- end }}
{{- if not (hasKey $securityContext "fsGroup") }}
fsGroup: {{ $defaults.fsGroup | default 1000 }}
{{- else if $securityContext.fsGroup }}
fsGroup: {{ $securityContext.fsGroup }}
{{- end }}
{{- if not (hasKey $securityContext "fsGroupChangePolicy") }}
fsGroupChangePolicy: {{ $defaults.fsGroupChangePolicy | default "OnRootMismatch" }}
{{- else if $securityContext.fsGroupChangePolicy }}
fsGroupChangePolicy: {{ $securityContext.fsGroupChangePolicy }}
{{- end }}
{{- with $securityContext.supplementalGroups }}
supplementalGroups:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.sysctls }}
sysctls:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.seLinuxOptions }}
seLinuxOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.windowsOptions }}
windowsOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if not (hasKey $securityContext "seccompProfile") }}
  {{- if $defaults.seccompProfile }}
seccompProfile:
  {{- toYaml $defaults.seccompProfile | nindent 2 }}
  {{- else }}
seccompProfile:
  type: RuntimeDefault
  {{- end }}
{{- else }}
  {{- with $securityContext.seccompProfile }}
seccompProfile:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Security-related annotations
Note: AppArmor is now configured via securityContext.appArmorProfile in Kubernetes 1.29+
*/}}
{{- define "generic.securityAnnotations" -}}
{{- $annotations := dict -}}
{{- toYaml $annotations -}}
{{- end -}}

{{/*
Pod Security Standards labels
*/}}
{{- define "generic.podSecurityStandardsLabels" -}}
{{- if .Values.security.podSecurityStandards.enforce -}}
pod-security.kubernetes.io/enforce: {{ .Values.security.podSecurityStandards.enforce }}
{{- end -}}
{{- if .Values.security.podSecurityStandards.audit -}}
pod-security.kubernetes.io/audit: {{ .Values.security.podSecurityStandards.audit }}
{{- end -}}
{{- if .Values.security.podSecurityStandards.warn -}}
pod-security.kubernetes.io/warn: {{ .Values.security.podSecurityStandards.warn }}
{{- end -}}
{{- end -}}

{{/*
Network Policy labels selector
*/}}
{{- define "generic.networkPolicySelector" -}}
{{- if .Values.networkPolicy.podSelector -}}
podSelector:
  {{- if .Values.networkPolicy.podSelector.matchLabels -}}
  matchLabels:
    {{- toYaml .Values.networkPolicy.podSelector.matchLabels | nindent 4 }}
  {{- else -}}
  matchLabels:
    {{- include "generic.selectorLabels" . | nindent 4 }}
  {{- end -}}
  {{- with .Values.networkPolicy.podSelector.matchExpressions -}}
  matchExpressions:
    {{- toYaml . | nindent 4 }}
  {{- end -}}
{{- else -}}
podSelector:
  matchLabels:
    {{- include "generic.selectorLabels" . | nindent 4 }}
{{- end -}}
{{- end -}}
