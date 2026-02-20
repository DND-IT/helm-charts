{{/*
Full ServiceAccount resource template.
Usage: {{- include "common.serviceaccount" . }}
*/}}
{{- define "common.serviceaccount" -}}
{{- if .Values.serviceAccount.enabled }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.serviceAccountName" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.serviceAccount.labels) | nindent 4 }}
  {{- if or .Values.serviceAccount.annotations .Values.commonAnnotations }}
  annotations:
    {{- if .Values.serviceAccount.annotations }}
    {{- range $key, $value := .Values.serviceAccount.annotations }}
    {{ $key }}: {{ include "common.tplValue" (dict "value" $value "context" $) | quote }}
    {{- end }}
    {{- end }}
    {{- with .Values.commonAnnotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken | default true }}
{{- end }}
{{- end -}}
