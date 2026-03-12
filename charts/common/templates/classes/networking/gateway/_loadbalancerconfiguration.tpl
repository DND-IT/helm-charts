{{/*
AWS Load Balancer Controller v3 LoadBalancerConfiguration resource template.
Usage: {{- include "common.loadBalancerConfiguration" . }}
*/}}
{{- define "common.loadBalancerConfiguration" -}}
{{- if and .Values.gateway.loadBalancerConfiguration .Values.gateway.loadBalancerConfiguration.enabled (.Capabilities.APIVersions.Has "gateway.k8s.aws/v1beta1/LoadBalancerConfiguration") }}
apiVersion: gateway.k8s.aws/v1beta1
kind: LoadBalancerConfiguration
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.loadBalancerConfiguration.labels) | nindent 4 }}
  {{- if or .Values.gateway.loadBalancerConfiguration.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.loadBalancerConfiguration.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.gateway.loadBalancerConfiguration.loadBalancerName }}
  loadBalancerName: {{ . }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.scheme }}
  scheme: {{ . }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.ipAddressType }}
  ipAddressType: {{ . }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.loadBalancerSubnets }}
  loadBalancerSubnets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.securityGroups }}
  securityGroups:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.sourceRanges }}
  sourceRanges:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.listenerConfigurations }}
  listenerConfigurations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.loadBalancerAttributes }}
  loadBalancerAttributes:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.tags }}
  tags:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.wafV2 }}
  wafV2:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.loadBalancerConfiguration.shieldConfiguration }}
  shieldConfiguration:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
