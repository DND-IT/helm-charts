{{/*
Common labels
*/}}
{{- define "common.labels" -}}
{{- $context := .context | default . -}}
{{- $labels := .labels | default dict -}}
helm.sh/chart: {{ include "common.chart" $context }}
{{ include "common.selectorLabels" $context }}
app.kubernetes.io/managed-by: {{ $context.Release.Service }}
{{- if $context.Values.image }}
app.kubernetes.io/version: {{ $context.Values.image.tag | quote }}
{{- end }}
{{- with $context.Values.commonLabels }}
{{- include "common.tplYaml" (dict "value" . "context" $context) | nindent 0 }}
{{- end }}
{{- with $labels }}
{{- include "common.tplYaml" (dict "value" . "context" $context) | nindent 0 }}
{{- end }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "common.annotations" -}}
{{- $context := .context | default . -}}
{{- $annotations := .annotations | default dict -}}
{{- with $context.Values.commonAnnotations }}
{{- include "common.tplYaml" (dict "value" . "context" $context) | nindent 0 }}
{{- end }}
{{- with $annotations }}
{{- include "common.tplYaml" (dict "value" . "context" $context) | nindent 0 }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Pod Security Standards labels
*/}}
{{- define "common.podSecurityStandardsLabels" -}}
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
