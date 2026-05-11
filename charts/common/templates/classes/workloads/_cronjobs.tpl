{{/*
Range-based CronJobs resource template (for multiple cronjobs via map).
Calls common.cronjob once per enabled entry under .Values.cronjobs.
Usage: {{- include "common.cronjobs" . }}
*/}}
{{- define "common.cronjobs" -}}
{{- range $name, $cronjob := .Values.cronjobs }}
{{- if $cronjob.enabled }}
---
{{ include "common.cronjob" (dict "name" $name "config" $cronjob "root" $) }}
{{- end }}
{{- end }}
{{- end -}}
