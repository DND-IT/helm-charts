{{/*
Single CronJob renderer.
Parameters:
- name: Component name for this CronJob entry (required)
- config: CronJob configuration dict (required)
- root: Root context (required)
*/}}
{{- define "common.cronjob" -}}
{{- $name := .name -}}
{{- $cronjob := .config -}}
{{- $root := .root -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "common.fullname" $root }}-{{ $name }}
  namespace: {{ include "common.namespace" $root }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" $name) ($cronjob.labels | default dict) }}
    {{- include "common.labels" (dict "context" $root "labels" $extraLabels) | nindent 4 }}
  {{- if or $cronjob.annotations $root.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $root "annotations" $cronjob.annotations) | nindent 4 }}
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
        {{- include "common.labels" (dict "context" $root "labels" $extraJobLabels) | nindent 8 }}
      {{- if or $cronjob.jobAnnotations $root.Values.commonAnnotations }}
      annotations:
        {{- include "common.annotations" (dict "context" $root "annotations" $cronjob.jobAnnotations) | nindent 8 }}
      {{- end }}
    spec:
      {{- include "common.jobSpec" (dict "job" $cronjob) | nindent 6 }}
      template:
        {{- include "common.podTemplate" (dict "root" $root "config" $cronjob "componentName" $name "defaultRestartPolicy" "OnFailure" "mainContainer" true) | nindent 8 }}
{{- end -}}
