{{/*
Gateway API UDPRoute resource template.
Usage: {{- include "common.udpRoute" . }}
*/}}
{{- define "common.udpRoute" -}}
{{- if and .Values.gateway.udpRoute .Values.gateway.udpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/UDPRoute") }}
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: UDPRoute
metadata:
  name: {{ include "common.fullname" . }}-udp
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.udpRoute.labels) | nindent 4 }}
  {{- if or .Values.gateway.udpRoute.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.udpRoute.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.gateway.udpRoute.parentRefs }}
  parentRefs:
    {{- include "common.gatewayParentRefs" . | nindent 4 }}
  {{- end }}
  rules:
    {{- if .Values.gateway.udpRoute.rules }}
    {{- range $rule := .Values.gateway.udpRoute.rules }}
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
Extra UDPRoutes resource template.
Usage: {{- include "common.extraUdpRoutes" . }}
*/}}
{{- define "common.extraUdpRoutes" -}}
{{- if and .Values.gateway.udpRoute .Values.gateway.udpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/UDPRoute") }}
{{- if .Values.gateway.udpRoute.extraRoutes }}
{{- range $name, $route := .Values.gateway.udpRoute.extraRoutes }}
{{- if $route.enabled | default true }}
---
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: UDPRoute
metadata:
  name: {{ printf "%s-%s-udp" (include "common.fullname" $) $name }}
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
