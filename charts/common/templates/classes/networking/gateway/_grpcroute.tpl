{{/*
Gateway API GRPCRoute resource template.
Usage: {{- include "common.grpcRoute" . }}
*/}}
{{- define "common.grpcRoute" -}}
{{- if and .Values.gateway.grpcRoute .Values.gateway.grpcRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/GRPCRoute") }}
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.grpcRoute.labels) | nindent 4 }}
  {{- if or .Values.gateway.grpcRoute.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.grpcRoute.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.gateway.grpcRoute.parentRefs }}
  parentRefs:
    {{- include "common.gatewayParentRefs" . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.grpcRoute.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- if .Values.gateway.grpcRoute.rules }}
    {{- range $rule := .Values.gateway.grpcRoute.rules }}
    - {{- with $rule.matches }}
      matches:
        {{- range $match := . }}
        - {{- with $match.method }}
          method:
            {{- if .type }}
            type: {{ .type }}
            {{- end }}
            {{- if .service }}
            service: {{ .service }}
            {{- end }}
            {{- if .method }}
            method: {{ .method }}
            {{- end }}
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
        {{- end }}
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
    - backendRefs:
        - name: {{ include "common.fullname" . }}
          port: {{ include "common.servicePort" . }}
    {{- end }}
{{- end }}
{{- end -}}

{{/*
Extra GRPCRoutes resource template.
Usage: {{- include "common.extraGrpcRoutes" . }}
*/}}
{{- define "common.extraGrpcRoutes" -}}
{{- if and .Values.gateway.grpcRoute .Values.gateway.grpcRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/GRPCRoute") }}
{{- if .Values.gateway.grpcRoute.extraRoutes }}
{{- range $name, $route := .Values.gateway.grpcRoute.extraRoutes }}
{{- if $route.enabled | default true }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
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
