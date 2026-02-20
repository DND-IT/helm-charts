{{/*
NetworkPolicy resource template.
Usage: {{- include "common.networkPolicy" . }}
*/}}
{{- define "common.networkPolicy" -}}
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  {{- with .Values.networkPolicy.policyTypes }}
  policyTypes:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.networkPolicy.ingress }}
  ingress:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.networkPolicy.egress }}
  egress:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
