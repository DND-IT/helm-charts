{{/*
Common labels
Pass "pod" true to include pod-specific labels (e.g. Datadog unified service tagging).
*/}}
{{- define "common.labels" -}}
{{- $context := .context | default . -}}
{{- $labels := .labels | default dict -}}
{{- $isPod := .pod | default false -}}
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
{{- if $isPod }}
{{- include "common.datadogLabels" (dict "context" $context) | nindent 0 }}
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
Datadog unified service tagging labels for pods.
Adds admission.datadoghq.com/enabled and tags.datadoghq.com/* labels.
Parameters:
- context: The root context
- labels: Existing pod labels to merge with
*/}}
{{- define "common.datadogLabels" -}}
{{- $context := .context | default . -}}
{{- if $context.Values.datadog.enabled -}}
{{- $ddService := $context.Values.datadog.service | default (include "common.fullname" $context) -}}
{{- $ddEnv := $context.Values.datadog.env | default $context.Release.Namespace -}}
{{- $ddVersion := $context.Values.datadog.version | default ($context.Values.image.tag | default "latest") -}}
admission.datadoghq.com/enabled: "true"
tags.datadoghq.com/service: {{ $ddService }}
tags.datadoghq.com/env: {{ $ddEnv }}
tags.datadoghq.com/version: {{ $ddVersion | quote }}
{{- end -}}
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
