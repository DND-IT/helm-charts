{{/*
Full CronJob resource template.
Usage: {{- include "common.cronjob" . }}
*/}}
{{- define "common.cronjob" -}}
{{- if .Values.schedule }}
apiVersion: batch/v1
kind: CronJob
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
  schedule: {{ .Values.schedule | quote }}
  concurrencyPolicy: {{ .Values.concurrencyPolicy | default "Forbid" }}
  successfulJobsHistoryLimit: {{ .Values.successfulJobsHistoryLimit | default 3 }}
  failedJobsHistoryLimit: {{ .Values.failedJobsHistoryLimit | default 1 }}
  {{- with .Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  suspend: {{ .Values.suspend | default false }}
  jobTemplate:
    metadata:
      labels:
        {{- include "common.labels" . | nindent 8 }}
    spec:
      {{- include "common.jobSpec" (dict "job" .Values.job) | nindent 6 }}
      template:
        {{- include "common.podTemplate" (dict "root" . "defaultRestartPolicy" "OnFailure") | nindent 8 }}
{{- end }}
{{- end -}}
