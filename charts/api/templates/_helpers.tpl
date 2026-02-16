{{/*
Expand the name of the chart.
*/}}
{{- define "api.name" -}}
{{- include "common.name" . -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "api.fullname" -}}
{{- include "common.fullname" . -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "api.chart" -}}
{{- include "common.chart" . -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "api.labels" -}}
{{- include "common.labels" . -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "api.selectorLabels" -}}
{{- include "common.selectorLabels" . -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "api.serviceAccountName" -}}
{{- include "common.serviceAccountName" . -}}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "api.namespace" -}}
{{- include "common.namespace" . -}}
{{- end }}
