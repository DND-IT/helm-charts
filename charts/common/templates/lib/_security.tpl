{{/*
Pod security context with secure defaults
*/}}
{{- define "common.podSecurityContext" -}}
{{- $securityContext := .securityContext | default dict -}}
{{- $defaults := .defaults | default dict -}}
{{- if not (hasKey $securityContext "runAsNonRoot") }}
runAsNonRoot: {{ hasKey $defaults "runAsNonRoot" | ternary $defaults.runAsNonRoot true }}
{{- else }}
runAsNonRoot: {{ $securityContext.runAsNonRoot }}
{{- end }}
{{- if not (hasKey $securityContext "runAsUser") }}
runAsUser: {{ hasKey $defaults "runAsUser" | ternary $defaults.runAsUser 1000 }}
{{- else }}
runAsUser: {{ $securityContext.runAsUser }}
{{- end }}
{{- if not (hasKey $securityContext "runAsGroup") }}
runAsGroup: {{ hasKey $defaults "runAsGroup" | ternary $defaults.runAsGroup 1000 }}
{{- else }}
runAsGroup: {{ $securityContext.runAsGroup }}
{{- end }}
{{- if not (hasKey $securityContext "fsGroup") }}
fsGroup: {{ hasKey $defaults "fsGroup" | ternary $defaults.fsGroup 1000 }}
{{- else }}
fsGroup: {{ $securityContext.fsGroup }}
{{- end }}
{{- if not (hasKey $securityContext "fsGroupChangePolicy") }}
fsGroupChangePolicy: {{ hasKey $defaults "fsGroupChangePolicy" | ternary $defaults.fsGroupChangePolicy "OnRootMismatch" }}
{{- else }}
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
Container security context with secure defaults
*/}}
{{- define "common.containerSecurityContext" -}}
{{- $securityContext := .securityContext | default dict -}}
{{- $root := .root -}}
{{- $defaults := $root.Values.security.defaultContainerSecurityContext | default dict -}}
{{- if hasKey $securityContext "runAsNonRoot" }}
runAsNonRoot: {{ $securityContext.runAsNonRoot }}
{{- else if hasKey $defaults "runAsNonRoot" }}
runAsNonRoot: {{ $defaults.runAsNonRoot }}
{{- end }}
{{- if hasKey $securityContext "runAsUser" }}
runAsUser: {{ $securityContext.runAsUser }}
{{- else if hasKey $defaults "runAsUser" }}
runAsUser: {{ $defaults.runAsUser }}
{{- end }}
{{- if not (hasKey $securityContext "allowPrivilegeEscalation") }}
allowPrivilegeEscalation: {{ hasKey $defaults "allowPrivilegeEscalation" | ternary $defaults.allowPrivilegeEscalation false }}
{{- else }}
allowPrivilegeEscalation: {{ $securityContext.allowPrivilegeEscalation }}
{{- end }}
{{- if not (hasKey $securityContext "readOnlyRootFilesystem") }}
readOnlyRootFilesystem: {{ $defaults.readOnlyRootFilesystem }}
{{- else }}
readOnlyRootFilesystem: {{ $securityContext.readOnlyRootFilesystem }}
{{- end }}
{{- if not (hasKey $securityContext "capabilities") }}
capabilities:
  drop:
  - ALL
  {{- with $defaults.capabilities }}
  {{- with .add }}
  add:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
{{- else }}
  {{- with $securityContext.capabilities }}
capabilities:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- with $securityContext.privileged }}
privileged: {{ . }}
{{- end }}
{{- with $securityContext.seLinuxOptions }}
seLinuxOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.windowsOptions }}
windowsOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.runAsGroup }}
runAsGroup: {{ . }}
{{- end }}
{{- with $securityContext.procMount }}
procMount: {{ . }}
{{- end }}
{{- if $securityContext.seccompProfile }}
seccompProfile:
  {{- toYaml $securityContext.seccompProfile | nindent 2 }}
{{- else if $defaults.seccompProfile }}
seccompProfile:
  {{- toYaml $defaults.seccompProfile | nindent 2 }}
{{- else }}
seccompProfile:
  type: RuntimeDefault
{{- end }}
{{- if $securityContext.appArmorProfile }}
appArmorProfile:
  {{- toYaml $securityContext.appArmorProfile | nindent 2 }}
{{- else if $defaults.appArmorProfile }}
appArmorProfile:
  {{- toYaml $defaults.appArmorProfile | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Security-related annotations
Note: AppArmor is now configured via securityContext.appArmorProfile in Kubernetes 1.29+
*/}}
{{- define "common.securityAnnotations" -}}
{{- $annotations := dict -}}
{{- toYaml $annotations -}}
{{- end -}}

{{/*
Network Policy labels selector
*/}}
{{- define "common.networkPolicySelector" -}}
{{- if .Values.networkPolicy.podSelector -}}
podSelector:
  {{- if .Values.networkPolicy.podSelector.matchLabels -}}
  matchLabels:
    {{- toYaml .Values.networkPolicy.podSelector.matchLabels | nindent 4 }}
  {{- else -}}
  matchLabels:
    {{- include "common.selectorLabels" . | nindent 4 }}
  {{- end -}}
  {{- with .Values.networkPolicy.podSelector.matchExpressions -}}
  matchExpressions:
    {{- toYaml . | nindent 4 }}
  {{- end -}}
{{- else -}}
podSelector:
  matchLabels:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end -}}
{{- end -}}
