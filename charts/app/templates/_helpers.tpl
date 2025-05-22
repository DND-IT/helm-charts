{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Release.Name .Values.app.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Release.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Values.app.version }}
app.kubernetes.io/version: {{ .Values.app.version | quote }}
{{- else if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the ConfigMap
*/}}
{{- define "app.configMapName" -}}
{{- if .Values.configMap.enabled }}
{{- printf "%s-config" (include "app.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the Secret
*/}}
{{- define "app.secretName" -}}
{{- if .Values.secret.enabled }}
{{- printf "%s-secret" (include "app.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the PVC
*/}}
{{- define "app.pvcName" -}}
{{- if .Values.persistence.enabled }}
{{- printf "%s-data" (include "app.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create image name
*/}}
{{- define "app.image" -}}
{{- if .Values.image.tag }}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository .Chart.AppVersion }}
{{- end }}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "app.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Render value with template support
*/}}
{{- define "app.tplValue" -}}
{{- if typeIs "string" .value }}
{{- tpl .value .context }}
{{- else }}
{{- tpl (.value | toYaml) .context }}
{{- end }}
{{- end }}

{{/*
Get the service port
*/}}
{{- define "app.servicePort" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).port | default .Values.service.port }}
{{- else }}
{{- .Values.service.port }}
{{- end }}
{{- end }}

{{/*
Get the service target port
*/}}
{{- define "app.serviceTargetPort" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).targetPort | default .Values.service.targetPort }}
{{- else }}
{{- .Values.service.targetPort }}
{{- end }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "app.validateValues" -}}
{{- if not .Values.image.repository }}
{{- fail "image.repository is required" }}
{{- end }}
{{- if and .Values.persistence.enabled (not .Values.persistence.size) }}
{{- fail "persistence.size is required when persistence is enabled" }}
{{- end }}
{{- end }}
