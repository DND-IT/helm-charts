{{/*
Full DaemonSet resource template.
Usage: {{- include "common.daemonset" . }}
*/}}
{{- define "common.daemonset" -}}
{{- if and (eq (.Values.workload.type | default "") "daemonset") .Values.image.repository }}
apiVersion: apps/v1
kind: DaemonSet
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
  {{- with .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: main
  {{- with .Values.daemonset.updateStrategy }}
  updateStrategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    {{- include "common.podTemplate" . | nindent 4 }}
{{- end }}
{{- end -}}
