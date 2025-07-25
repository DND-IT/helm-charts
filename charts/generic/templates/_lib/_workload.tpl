{{/*
Workload selector - routes to the appropriate workload type
*/}}
{{- define "generic.workload" -}}
{{- $workloadType := .Values.workload.type | default "deployment" -}}
{{- if eq $workloadType "deployment" -}}
  {{- include "generic.deployment" . -}}
{{- else if eq $workloadType "statefulset" -}}
  {{- include "generic.statefulset" . -}}
{{- else if eq $workloadType "daemonset" -}}
  {{- include "generic.daemonset" . -}}
{{- else if eq $workloadType "job" -}}
  {{- include "generic.job" . -}}
{{- else if eq $workloadType "cronjob" -}}
  {{- include "generic.cronjob" . -}}
{{- else -}}
  {{- fail (printf "Unknown workload type: %s. Valid types are: deployment, statefulset, daemonset, job, cronjob" $workloadType) -}}
{{- end -}}
{{- end -}}

{{/*
Validate workload configuration
*/}}
{{- define "generic.validateWorkload" -}}
{{- $workloadType := .Values.workload.type | default "deployment" -}}
{{- $validTypes := list "deployment" "statefulset" "daemonset" "job" "cronjob" -}}
{{- if not (has $workloadType $validTypes) -}}
  {{- fail (printf "workload.type must be one of: %s" (join ", " $validTypes)) -}}
{{- end -}}
{{/* Validate StatefulSet specific requirements */}}
{{- if eq $workloadType "statefulset" -}}
  {{- if not .Values.service.enabled -}}
    {{- fail "StatefulSet requires service.enabled to be true" -}}
  {{- end -}}
  {{- if and .Values.autoscaling.enabled (not .Values.workload.podManagementPolicy) -}}
    {{- fail "StatefulSet with HPA requires workload.podManagementPolicy to be set to 'Parallel'" -}}
  {{- end -}}
{{- end -}}
{{/* Validate Job/CronJob specific requirements */}}
{{- if or (eq $workloadType "job") (eq $workloadType "cronjob") -}}
  {{- if .Values.autoscaling.enabled -}}
    {{- fail "Jobs and CronJobs do not support autoscaling" -}}
  {{- end -}}
  {{- if .Values.deployment.strategy -}}
    {{- fail "Jobs and CronJobs do not support deployment strategies" -}}
  {{- end -}}
{{- end -}}
{{/* Validate CronJob specific requirements */}}
{{- if eq $workloadType "cronjob" -}}
  {{- if not .Values.workload.schedule -}}
    {{- fail "CronJob requires workload.schedule to be set" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common workload metadata
*/}}
{{- define "generic.workloadMetadata" }}
metadata:
  name: {{ include "generic.fullname" . }}
  namespace: {{ include "generic.namespace" . }}
  labels:
    {{- include "generic.labels" . | nindent 4 }}
    {{- range $key, $value := .Values.workloadLabels }}
    {{ $key }}: {{ include "generic.tplValue" (dict "value" $value "context" $) | quote }}
    {{- end }}
  {{- with .Values.workloadAnnotations }}
  annotations:
    {{- range $key, $value := . }}
    {{ $key }}: {{ include "generic.tplValue" (dict "value" $value "context" $) | quote }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Common pod template spec
*/}}
{{- define "generic.podTemplateSpec" -}}
template:
  {{- include "generic.podTemplate" . | nindent 2 }}
{{- end -}}
