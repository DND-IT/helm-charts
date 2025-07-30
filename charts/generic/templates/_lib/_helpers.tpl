{{/*
Expand the name of the chart.
*/}}
{{- define "generic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
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
{{- $context := .context | default . -}}
{{- $labels := .labels | default dict -}}
helm.sh/chart: {{ include "generic.chart" $context }}
{{ include "generic.selectorLabels" $context }}
app.kubernetes.io/managed-by: {{ $context.Release.Service }}
{{- with $context.Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- with $labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "generic.annotations" -}}
{{- $context := .context | default . -}}
{{- $annotations := .annotations | default dict -}}
{{- with $context.Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- with $annotations }}
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

{{/*
Process topology spread constraints to add labelSelector if not specified
Usage:
  {{- include "generic.topologySpreadConstraints" . }}
Or with component name:
  {{- include "generic.topologySpreadConstraints" (dict "context" . "componentName" "worker") }}
*/}}
{{- define "generic.topologySpreadConstraints" -}}
{{- $context := .context | default . -}}
{{- $componentName := .componentName | default "" -}}
{{- $constraints := .Values.topologySpreadConstraints | default $context.Values.topologySpreadConstraints -}}
{{- $selectorLabels := include "generic.selectorLabels" $context | fromYaml -}}
{{- if $componentName -}}
  {{- $selectorLabels = merge $selectorLabels (dict "app.kubernetes.io/component" $componentName) -}}
{{- end -}}
{{- range $constraint := $constraints }}
- maxSkew: {{ $constraint.maxSkew }}
  topologyKey: {{ $constraint.topologyKey }}
  whenUnsatisfiable: {{ $constraint.whenUnsatisfiable }}
  {{- if $constraint.labelSelector }}
  labelSelector:
    {{- toYaml $constraint.labelSelector | nindent 4 }}
  {{- else }}
  labelSelector:
    matchLabels:
      {{- toYaml $selectorLabels | nindent 6 }}
  {{- end }}
  {{- if $constraint.minDomains }}
  minDomains: {{ $constraint.minDomains }}
  {{- end }}
  {{- if $constraint.nodeAffinityPolicy }}
  nodeAffinityPolicy: {{ $constraint.nodeAffinityPolicy }}
  {{- end }}
  {{- if $constraint.nodeTaintsPolicy }}
  nodeTaintsPolicy: {{ $constraint.nodeTaintsPolicy }}
  {{- end }}
  {{- if $constraint.matchLabelKeys }}
  matchLabelKeys:
    {{- toYaml $constraint.matchLabelKeys | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end }}
