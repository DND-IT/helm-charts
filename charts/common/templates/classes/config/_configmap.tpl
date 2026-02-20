{{/*
Full ConfigMap resource template.
Usage: {{- include "common.configmap" . }}
*/}}
{{- define "common.configmap" -}}
{{- if .Values.configMap.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.configMapName" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.configMap.labels) | nindent 4 }}
  {{- if or .Values.configMap.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.configMap.annotations) | nindent 4 }}
  {{- end }}
{{- if or .Values.configMap.data .Values.configMap.binaryData }}
{{- with .Values.configMap.data }}
data:
  {{- range $key, $value := . }}
  {{- if kindIs "string" $value }}
  {{ $key }}: {{ include "common.tplValue" (dict "value" $value "context" $) | quote }}
  {{- else }}
  {{ $key }}: |
    {{- include "common.tplValue" (dict "value" ($value | toYaml) "context" $) | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- with .Values.configMap.binaryData }}
binaryData:
  {{- range $key, $value := . }}
  {{ $key }}: {{ $value }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Extra ConfigMaps template.
Usage: {{- include "common.extraConfigMaps" . }}
*/}}
{{- define "common.extraConfigMaps" -}}
{{- range $name, $configMap := .Values.extraConfigMaps }}
{{- if $configMap.enabled | default true }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- include "common.labels" (dict "context" $ "labels" $configMap.labels) | nindent 4 }}
  {{- if or $configMap.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $configMap.annotations) | nindent 4 }}
  {{- end }}
{{- if or $configMap.data $configMap.binaryData }}
{{- with $configMap.data }}
data:
  {{- range $key, $value := . }}
  {{- if kindIs "string" $value }}
  {{ $key }}: {{ include "common.tplValue" (dict "value" $value "context" $) | quote }}
  {{- else }}
  {{ $key }}: |
    {{- include "common.tplValue" (dict "value" ($value | toYaml) "context" $) | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- with $configMap.binaryData }}
binaryData:
  {{- range $key, $value := . }}
  {{ $key }}: {{ $value }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
