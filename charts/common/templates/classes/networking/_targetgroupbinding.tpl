{{/*
AWS TargetGroupBinding resource template.
Usage: {{- include "common.targetGroupBinding" . }}
*/}}
{{- define "common.targetGroupBinding" -}}
{{- if .Values.targetGroupBinding.enabled -}}
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.targetGroupBinding.labels) | nindent 4 }}
  {{- if or .Values.targetGroupBinding.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.targetGroupBinding.annotations) | nindent 4 }}
  {{- end }}
spec:
  serviceRef:
    name: {{ .Values.targetGroupBinding.serviceRef.name | default (include "common.fullname" .) }}
    port: {{ .Values.targetGroupBinding.serviceRef.port | default "http" }}
  targetGroupARN: {{ .Values.targetGroupBinding.targetGroupARN }}
  {{- with .Values.targetGroupBinding.targetType }}
  targetType: {{ . }}
  {{- end }}
  {{- with .Values.targetGroupBinding.ipAddressType }}
  ipAddressType: {{ . }}
  {{- end }}
  {{- with .Values.targetGroupBinding.networking }}
  networking:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Extra AWS TargetGroupBindings resource template.
Usage: {{- include "common.extraTargetGroupBindings" . }}
*/}}
{{- define "common.extraTargetGroupBindings" -}}
{{- range $name, $binding := .Values.extraTargetGroupBindings }}
{{- if $binding.enabled }}
---
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: {{ include "common.fullname" $ }}-{{ $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" $name) ($binding.labels | default dict) }}
    {{- include "common.labels" (dict "context" $ "labels" $extraLabels) | nindent 4 }}
  {{- if or $binding.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $binding.annotations) | nindent 4 }}
  {{- end }}
spec:
  serviceRef:
    {{- if $binding.serviceRef }}
    name: {{ $binding.serviceRef.name | default (include "common.fullname" $) }}
    port: {{ $binding.serviceRef.port | default "http" }}
    {{- else }}
    name: {{ include "common.fullname" $ }}
    port: "http"
    {{- end }}
  targetGroupARN: {{ $binding.targetGroupARN }}
  {{- with $binding.targetType }}
  targetType: {{ . }}
  {{- end }}
  {{- with $binding.ipAddressType }}
  ipAddressType: {{ . }}
  {{- end }}
  {{- with $binding.networking }}
  networking:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}
