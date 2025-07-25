{{/*
Expand the name of the chart.
*/}}
{{- define "generic.name" -}}
{{- default .Release.Name .Values.generic.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic.fullname" -}}
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
{{- define "generic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic.labels" -}}
helm.sh/chart: {{ include "generic.chart" . }}
{{ include "generic.selectorLabels" . }}
{{- if .Values.generic.version }}
app.kubernetes.io/version: {{ .Values.generic.version | quote }}
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
{{- define "generic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "generic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "generic.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled }}
{{- if .Values.serviceAccount.name }}
{{- include "generic.tplValue" (dict "value" .Values.serviceAccount.name "context" .) }}
{{- else }}
{{- include "generic.fullname" . }}
{{- end }}
{{- else }}
{{- if .Values.serviceAccount.name }}
{{- include "generic.tplValue" (dict "value" .Values.serviceAccount.name "context" .) }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the ConfigMap
*/}}
{{- define "generic.configMapName" -}}
{{- if .Values.configMap.enabled }}
{{- printf "%s-config" (include "generic.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the Secret
*/}}
{{- define "generic.secretName" -}}
{{- if .Values.secret.enabled }}
{{- printf "%s-secret" (include "generic.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the PVC
*/}}
{{- define "generic.pvcName" -}}
{{- if .Values.persistence.enabled }}
{{- printf "%s-data" (include "generic.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create image name
*/}}
{{- define "generic.image" -}}
{{- if .Values.image.tag }}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository .Chart.AppVersion }}
{{- end }}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "generic.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- include "generic.tplValue" (dict "value" .Values.namespaceOverride "context" .) }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Render value with template support
*/}}
{{- define "generic.tplValue" -}}
{{- if typeIs "string" .value }}
{{- tpl .value .context }}
{{- else }}
{{- tpl (.value | toYaml) .context }}
{{- end }}
{{- end }}

{{/*
Get the service port
*/}}
{{- define "generic.servicePort" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).port | default .Values.service.port }}
{{- else }}
{{- .Values.service.port }}
{{- end }}
{{- end }}

{{/*
Get the service target port
*/}}
{{- define "generic.serviceTargetPort" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).targetPort | default .Values.service.targetPort }}
{{- else }}
{{- .Values.service.targetPort }}
{{- end }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "generic.validateValues" -}}
{{- if not .Values.image.repository }}
{{- fail "image.repository is required" }}
{{- end }}
{{- if and .Values.persistence.enabled (not .Values.persistence.size) }}
{{- fail "persistence.size is required when persistence is enabled" }}
{{- end }}
{{- end }}

{{/*
Get the preferred API version for a resource
Usage: {{ include "generic.apiVersion" (dict "kind" "ExternalSecret" "group" "external-secrets.io" "versions" (list "v1" "v1beta1") "context" .) }}
*/}}
{{- define "generic.apiVersion" -}}
{{- $group := .group -}}
{{- $kind := .kind -}}
{{- $preferredVersion := "" -}}
{{- range .versions -}}
  {{- if $.context.Capabilities.APIVersions.Has (printf "%s/%s/%s" $group . $kind) -}}
    {{- $preferredVersion = printf "%s/%s" $group . -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- $preferredVersion -}}
{{- end }}
