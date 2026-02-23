{{/*
Expand the name of the chart.
*/}}
{{- define "worker.name" -}}
{{- include "common.name" . -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "worker.fullname" -}}
{{- include "common.fullname" . -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "worker.chart" -}}
{{- include "common.chart" . -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "worker.labels" -}}
{{- include "common.labels" . -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "worker.selectorLabels" -}}
{{- include "common.selectorLabels" . -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "worker.serviceAccountName" -}}
{{- include "common.serviceAccountName" . -}}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "worker.namespace" -}}
{{- include "common.namespace" . -}}
{{- end }}
