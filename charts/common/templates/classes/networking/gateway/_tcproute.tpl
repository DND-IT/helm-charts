{{/*
Gateway API TCPRoute resource template.
Usage: {{- include "common.tcpRoute" . }}
*/}}
{{- define "common.tcpRoute" -}}
{{- if and .Values.gateway.tcpRoute .Values.gateway.tcpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TCPRoute") }}
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: {{ include "common.fullname" . }}-tcp
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.tcpRoute.labels) | nindent 4 }}
  {{- if or .Values.gateway.tcpRoute.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.tcpRoute.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.gateway.tcpRoute.parentRefs }}
  parentRefs:
    {{- include "common.gatewayParentRefs" . | nindent 4 }}
  {{- end }}
  rules:
    {{- if .Values.gateway.tcpRoute.rules }}
    {{- range $rule := .Values.gateway.tcpRoute.rules }}
    - backendRefs:
        {{- range $backendRef := $rule.backendRefs }}
        - {{- include "common.gatewayBackendRef" $backendRef | nindent 10 }}
        {{- end }}
    {{- end }}
    {{- else }}
    # Default rule
    - backendRefs:
        - name: {{ include "common.fullname" . }}
          port: {{ include "common.servicePort" . }}
    {{- end }}
{{- end }}
{{- end -}}

{{/*
Extra TCPRoutes resource template.
Usage: {{- include "common.extraTcpRoutes" . }}
*/}}
{{- define "common.extraTcpRoutes" -}}
{{- if and .Values.gateway.tcpRoute .Values.gateway.tcpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TCPRoute") }}
{{- if .Values.gateway.tcpRoute.extraRoutes }}
{{- range $name, $route := .Values.gateway.tcpRoute.extraRoutes }}
{{- if $route.enabled | default true }}
---
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: {{ printf "%s-%s-tcp" (include "common.fullname" $) $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
    {{- with $route.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $route.parentRefs }}
  parentRefs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $route.rules }}
  rules:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
