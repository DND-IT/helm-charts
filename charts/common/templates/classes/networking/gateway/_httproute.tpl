{{/*
Gateway API HTTPRoute resource template.
Usage: {{- include "common.httpRoute" . }}
*/}}
{{- define "common.httpRoute" -}}
{{- if and .Values.gateway.httpRoute .Values.gateway.httpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute") }}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.httpRoute.labels) | nindent 4 }}
  {{- if or .Values.gateway.httpRoute.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.httpRoute.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.gateway.httpRoute.parentRefs }}
  parentRefs:
    {{- include "common.gatewayParentRefs" . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.httpRoute.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- if .Values.gateway.httpRoute.rules }}
    {{- range $rule := .Values.gateway.httpRoute.rules }}
    - matches:
        {{- if $rule.matches }}
        {{- range $match := $rule.matches }}
        - {{- with $match.path }}
          path:
            type: {{ .type | default "PathPrefix" }}
            value: {{ .value | default "/" }}
          {{- end }}
          {{- with $match.headers }}
          headers:
            {{- range $header := . }}
            - {{- if $header.type }}
              type: {{ $header.type }}
              {{- end }}
              name: {{ $header.name }}
              {{- if $header.value }}
              value: {{ $header.value }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- with $match.queryParams }}
          queryParams:
            {{- range $param := . }}
            - {{- if $param.type }}
              type: {{ $param.type }}
              {{- end }}
              name: {{ $param.name }}
              {{- if $param.value }}
              value: {{ $param.value }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- with $match.method }}
          method: {{ . }}
          {{- end }}
        {{- end }}
        {{- else }}
        - path:
            type: PathPrefix
            value: /
        {{- end }}
      {{- with $rule.filters }}
      filters:
        {{- include "common.gatewayFilters" . | nindent 8 }}
      {{- end }}
      backendRefs:
        {{- if $rule.backendRefs }}
        {{- range $backendRef := $rule.backendRefs }}
        - {{- include "common.gatewayBackendRef" $backendRef | nindent 10 }}
        {{- end }}
        {{- else }}
        - name: {{ include "common.fullname" $ }}
          port: {{ include "common.servicePort" $ }}
        {{- end }}
    {{- end }}
    {{- else }}
    # Default rule
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: {{ include "common.fullname" . }}
          port: {{ include "common.servicePort" . }}
    {{- end }}
{{- end }}
{{- end -}}

{{/*
Extra HTTPRoutes resource template.
Usage: {{- include "common.extraHttpRoutes" . }}
*/}}
{{- define "common.extraHttpRoutes" -}}
{{- if and .Values.gateway.httpRoute .Values.gateway.httpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute") }}
{{- if .Values.gateway.httpRoute.extraRoutes }}
{{- range $name, $route := .Values.gateway.httpRoute.extraRoutes }}
{{- if $route.enabled | default true }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ printf "%s-%s" (include "common.fullname" $) $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- include "common.labels" (dict "context" $ "labels" $route.labels) | nindent 4 }}
  {{- if or $route.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $route.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with $route.parentRefs }}
  parentRefs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $route.hostnames }}
  hostnames:
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
