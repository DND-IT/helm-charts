{{/*
Range-based CronJobs resource template (for multiple cronjobs via map).
Usage: {{- include "common.cronjobs" . }}
*/}}
{{- define "common.cronjobs" -}}
{{- range $name, $cronjob := .Values.cronjobs }}
{{- if $cronjob.enabled }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "common.fullname" $ }}-{{ $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" $name) ($cronjob.labels | default dict) }}
    {{- include "common.labels" (dict "context" $ "labels" $extraLabels) | nindent 4 }}
  {{- if or $cronjob.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $cronjob.annotations) | nindent 4 }}
  {{- end }}
spec:
  schedule: {{ $cronjob.schedule | quote }}
  {{- with $cronjob.timeZone }}
  timeZone: {{ . | quote }}
  {{- end }}
  {{- with $cronjob.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with $cronjob.concurrencyPolicy }}
  concurrencyPolicy: {{ . }}
  {{- end }}
  {{- with $cronjob.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with $cronjob.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with $cronjob.suspend }}
  suspend: {{ . }}
  {{- end }}
  jobTemplate:
    metadata:
      labels:
        {{- $extraJobLabels := merge (dict "app.kubernetes.io/component" $name) ($cronjob.jobLabels | default dict) }}
        {{- include "common.labels" (dict "context" $ "labels" $extraJobLabels) | nindent 8 }}
      {{- if or $cronjob.jobAnnotations $.Values.commonAnnotations }}
      annotations:
        {{- include "common.annotations" (dict "context" $ "annotations" $cronjob.jobAnnotations) | nindent 8 }}
      {{- end }}
    spec:
      {{- include "common.jobSpec" (dict "job" $cronjob) | nindent 6 }}
      template:
        {{- include "common.podTemplate" (dict "root" $ "config" $cronjob "componentName" $name "defaultRestartPolicy" "OnFailure") | nindent 8 }}
{{- end }}
{{- end }}
{{- end -}}
