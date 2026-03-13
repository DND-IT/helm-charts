{{/*
Job spec fields shared between Job, CronJob, and Hook resources.
Parameters:
- job: Job configuration dict
*/}}
{{- define "common.jobSpec" -}}
{{- $job := .job -}}
{{- with $job.completions }}
completions: {{ . }}
{{- end }}
{{- with $job.parallelism }}
parallelism: {{ . }}
{{- end }}
{{- with $job.backoffLimit }}
backoffLimit: {{ . }}
{{- end }}
{{- with $job.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ . }}
{{- end }}
{{- with $job.ttlSecondsAfterFinished }}
ttlSecondsAfterFinished: {{ . }}
{{- end }}
{{- with $job.completionMode }}
completionMode: {{ . }}
{{- end }}
{{- with $job.suspend }}
suspend: {{ . }}
{{- end }}
{{- with $job.podFailurePolicy }}
podFailurePolicy:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Job resource template.
Usage: {{- include "common.jobs" . }}
*/}}
{{- define "common.jobs" -}}
{{- range $name, $job := .Values.jobs }}
{{- if $job.enabled }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "common.fullname" $ }}-{{ $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" $name) ($job.labels | default dict) }}
    {{- include "common.labels" (dict "context" $ "labels" $extraLabels) | nindent 4 }}
  {{- if or $job.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $job.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- include "common.jobSpec" (dict "job" $job) | nindent 2 }}
  template:
    {{- include "common.podTemplate" (dict "root" $ "config" $job "componentName" $name "defaultRestartPolicy" "OnFailure") | nindent 4 }}
{{- end }}
{{- end }}
{{- end -}}
