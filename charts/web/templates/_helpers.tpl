{{/*
Expand the name of the chart.
*/}}
{{- define "web.name" -}}
{{- include "common.name" . -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "web.fullname" -}}
{{- include "common.fullname" . -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "web.chart" -}}
{{- include "common.chart" . -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "web.labels" -}}
{{- include "common.labels" . -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "web.selectorLabels" -}}
{{- include "common.selectorLabels" . -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "web.serviceAccountName" -}}
{{- include "common.serviceAccountName" . -}}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "web.namespace" -}}
{{- include "common.namespace" . -}}
{{- end }}
