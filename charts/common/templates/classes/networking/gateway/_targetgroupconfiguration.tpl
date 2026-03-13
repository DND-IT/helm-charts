{{/*
AWS Load Balancer Controller v3 TargetGroupConfiguration resource template.
Usage: {{- include "common.targetGroupConfiguration" . }}
*/}}
{{- define "common.targetGroupConfiguration" -}}
{{- if and .Values.gateway.targetGroupConfiguration .Values.gateway.targetGroupConfiguration.enabled (.Capabilities.APIVersions.Has "gateway.k8s.aws/v1beta1/TargetGroupConfiguration") }}
apiVersion: gateway.k8s.aws/v1beta1
kind: TargetGroupConfiguration
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.targetGroupConfiguration.labels) | nindent 4 }}
  {{- if or .Values.gateway.targetGroupConfiguration.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.targetGroupConfiguration.annotations) | nindent 4 }}
  {{- end }}
spec:
  targetReference:
    name: {{ (.Values.gateway.targetGroupConfiguration.targetReference).name | default (include "common.fullname" .) }}
    {{- with (.Values.gateway.targetGroupConfiguration.targetReference).group }}
    group: {{ . }}
    {{- end }}
    {{- with (.Values.gateway.targetGroupConfiguration.targetReference).kind }}
    kind: {{ . }}
    {{- end }}
  {{- with .Values.gateway.targetGroupConfiguration.defaultConfiguration }}
  defaultConfiguration:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.targetGroupConfiguration.routeConfigurations }}
  routeConfigurations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
