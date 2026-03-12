{{/*
Gateway API TLSRoute resource template.
Usage: {{- include "common.tlsRoute" . }}
*/}}
{{- define "common.tlsRoute" -}}
{{- if and .Values.gateway.tlsRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute") }}
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TLSRoute
metadata:
  name: {{ include "common.fullname" . }}-tls
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.gateway.tlsRoute.labels) | nindent 4 }}
  {{- if or .Values.gateway.tlsRoute.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.gateway.tlsRoute.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.gateway.tlsRoute.parentRefs }}
  parentRefs:
    {{- range $parentRef := .Values.gateway.tlsRoute.parentRefs }}
    - {{- if $parentRef.group }}
      group: {{ $parentRef.group }}
      {{- end }}
      {{- if $parentRef.kind }}
      kind: {{ $parentRef.kind }}
      {{- end }}
      {{- if $parentRef.namespace }}
      namespace: {{ $parentRef.namespace }}
      {{- end }}
      name: {{ $parentRef.name }}
      {{- with $parentRef.sectionName }}
      sectionName: {{ . }}
      {{- end }}
      {{- with $parentRef.port }}
      port: {{ . }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if .Values.gateway.tlsRoute.hostnames }}
  hostnames:
    {{- toYaml .Values.gateway.tlsRoute.hostnames | nindent 4 }}
  {{- end }}
  rules:
    {{- if .Values.gateway.tlsRoute.rules }}
    {{- range $rule := .Values.gateway.tlsRoute.rules }}
    - backendRefs:
        {{- range $backendRef := $rule.backendRefs }}
        - {{- if $backendRef.group }}
          group: {{ $backendRef.group }}
          {{- end }}
          {{- if $backendRef.kind }}
          kind: {{ $backendRef.kind }}
          {{- end }}
          {{- if $backendRef.namespace }}
          namespace: {{ $backendRef.namespace }}
          {{- end }}
          name: {{ $backendRef.name }}
          {{- with $backendRef.port }}
          port: {{ . }}
          {{- end }}
          {{- with $backendRef.weight }}
          weight: {{ . }}
          {{- end }}
        {{- end }}
    {{- end }}
    {{- else }}
    # Default rule
    - backendRefs:
        - name: {{ include "common.fullname" . }}
          port: {{ (index .Values.service.ports 0).port | default 80 }}
    {{- end }}
{{- end }}
{{- end -}}

{{/*
Extra TLSRoutes resource template.
Usage: {{- include "common.extraTlsRoutes" . }}
*/}}
{{- define "common.extraTlsRoutes" -}}
{{- if and .Values.gateway.tlsRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute") }}
{{- if .Values.gateway.tlsRoute.extraRoutes }}
{{- range $name, $route := .Values.gateway.tlsRoute.extraRoutes }}
{{- if $route.enabled | default true }}
---
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TLSRoute
metadata:
  name: {{ printf "%s-%s-tls" (include "common.fullname" $) $name }}
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
