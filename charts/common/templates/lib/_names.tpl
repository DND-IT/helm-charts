{{/*
Create a default name.
*/}}
{{- define "common.name" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
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
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create namespace
*/}}
{{- define "common.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- include "common.tplValue" (dict "value" .Values.namespaceOverride "context" .) }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled }}
{{- if .Values.serviceAccount.name }}
{{- include "common.tplValue" (dict "value" .Values.serviceAccount.name "context" .) }}
{{- else }}
{{- include "common.fullname" . }}
{{- end }}
{{- else }}
{{- if .Values.serviceAccount.name }}
{{- include "common.tplValue" (dict "value" .Values.serviceAccount.name "context" .) }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the ConfigMap
*/}}
{{- define "common.configMapName" -}}
{{- if .Values.configMap.enabled }}
{{- printf "%s-config" (include "common.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the Secret
*/}}
{{- define "common.secretName" -}}
{{- if .Values.secret.enabled }}
{{- printf "%s-secret" (include "common.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the PVC
*/}}
{{- define "common.pvcName" -}}
{{- if .Values.persistence.enabled }}
{{- printf "%s-data" (include "common.fullname" .) }}
{{- end }}
{{- end }}
