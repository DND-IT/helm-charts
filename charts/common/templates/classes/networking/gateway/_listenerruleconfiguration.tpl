{{/*
AWS Load Balancer Controller v3 ListenerRuleConfiguration resource template.
Usage: {{- include "common.listenerRuleConfiguration" . }}
*/}}
{{- define "common.listenerRuleConfiguration" -}}
{{- if and .Values.gateway.listenerRuleConfiguration .Values.gateway.listenerRuleConfiguration.enabled (.Capabilities.APIVersions.Has "gateway.k8s.aws/v1beta1/ListenerRuleConfiguration") }}
apiVersion: gateway.k8s.aws/v1beta1
kind: ListenerRuleConfiguration
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.listenerRuleConfiguration.labels) | nindent 4 }}
  {{- if or .Values.gateway.listenerRuleConfiguration.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.listenerRuleConfiguration.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.gateway.listenerRuleConfiguration.targetRef }}
  targetRef:
    name: {{ .name }}
    {{- with .namespace }}
    namespace: {{ . }}
    {{- end }}
    {{- with .group }}
    group: {{ . }}
    {{- end }}
    {{- with .kind }}
    kind: {{ . }}
    {{- end }}
  {{- end }}
  {{- with .Values.gateway.listenerRuleConfiguration.conditions }}
  conditions:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.listenerRuleConfiguration.actions }}
  actions:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.listenerRuleConfiguration.tags }}
  tags:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
