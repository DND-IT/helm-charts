{{/*
Extra Objects resource template for arbitrary Kubernetes resources.
Usage: {{- include "common.extraObjects" . }}
*/}}
{{- define "common.extraObjects" -}}
{{- $root := . -}}
{{- range .Values.extraObjects }}
---
{{- if typeIs "string" . }}
{{- include "common.tplValue" (dict "value" . "context" $root) | nindent 0 }}
{{- else }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}
{{- end -}}
