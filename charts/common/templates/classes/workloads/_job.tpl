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
Single Job renderer.
Parameters:
- name: Component name for this Job entry (required)
- config: Job configuration dict (required)
- root: Root context (required)
*/}}
{{- define "common.job" -}}
{{- $name := .name -}}
{{- $job := .config -}}
{{- $root := .root -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "common.fullname" $root }}-{{ $name }}
  namespace: {{ include "common.namespace" $root }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" $name) ($job.labels | default dict) }}
    {{- include "common.labels" (dict "context" $root "labels" $extraLabels) | nindent 4 }}
  {{- if or $job.annotations $root.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $root "annotations" $job.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- include "common.jobSpec" (dict "job" $job) | nindent 2 }}
  template:
    {{- include "common.podTemplate" (dict "root" $root "config" $job "componentName" $name "defaultRestartPolicy" "OnFailure" "mainContainer" true) | nindent 4 }}
{{- end -}}

{{/*
Range-based Jobs resource template (for multiple jobs via map).
Calls common.job once per enabled entry under .Values.jobs.
Usage: {{- include "common.jobs" . }}
*/}}
{{- define "common.jobs" -}}
{{- range $name, $job := .Values.jobs }}
{{- if $job.enabled }}
---
{{ include "common.job" (dict "name" $name "config" $job "root" $) }}
{{- end }}
{{- end }}
{{- end -}}
