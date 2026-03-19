{{/*
Full Deployment resource template.
Usage: {{- include "common.deployment" . }}
*/}}
{{- define "common.deployment" -}}
{{- include "common.validateValues" . -}}
{{- if eq (.Values.workload.type | default "deployment") "deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.workloadLabels) | nindent 4 }}
  {{- if or .Values.workloadAnnotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.workloadAnnotations) | nindent 4 }}
  {{- end }}
spec:
  {{- if not .Values.hpa.enabled }}
  replicas: {{ .Values.replicas | default 1 }}
  {{- end }}
  {{- with .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: main
  {{- with .Values.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    {{- include "common.podTemplate" . | nindent 4 }}
{{- end }}
{{- end -}}

{{/*
Extra Deployments template (for generic chart advanced use cases).
Usage: {{- include "common.extraDeployments" . }}
*/}}
{{- define "common.extraDeployments" -}}
{{- range $name, $deployment := .Values.extraDeployments }}
{{- if ne (toString $deployment.enabled) "false" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" $ }}-{{ $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" $name) ($deployment.labels | default dict) }}
    {{- include "common.labels" (dict "context" $ "labels" $extraLabels) | nindent 4 }}
  {{- if or $deployment.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $deployment.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- if not $deployment.hpa }}
  replicas: {{ $deployment.replicas | default 1 }}
  {{- end }}
  {{- with $deployment.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  {{- with $deployment.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with $deployment.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" $ | nindent 6 }}
      app.kubernetes.io/component: {{ $name }}
  {{- with $deployment.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    {{- include "common.podTemplate" (dict "root" $ "config" $deployment "componentName" $name) | nindent 4 }}
{{- end }}
{{- end }}
{{- end -}}
