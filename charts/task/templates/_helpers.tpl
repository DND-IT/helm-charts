{{/*
Expand the name of the chart.
*/}}
{{- define "task.name" -}}
{{- include "common.name" . -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "task.fullname" -}}
{{- include "common.fullname" . -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "task.chart" -}}
{{- include "common.chart" . -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "task.labels" -}}
{{- include "common.labels" . -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "task.selectorLabels" -}}
{{- include "common.selectorLabels" . -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "task.serviceAccountName" -}}
{{- include "common.serviceAccountName" . -}}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "task.namespace" -}}
{{- include "common.namespace" . -}}
{{- end }}
