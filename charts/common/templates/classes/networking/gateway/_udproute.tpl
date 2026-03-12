{{/*
Gateway API UDPRoute resource template.
Usage: {{- include "common.udpRoute" . }}
*/}}
{{- define "common.udpRoute" -}}
{{- if and .Values.gateway.udpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/UDPRoute") }}
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
  {{- if .Values.gateway.udpRoute.parentRefs }}
  parentRefs:
    {{- range $parentRef := .Values.gateway.udpRoute.parentRefs }}
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
  rules:
    {{- if .Values.gateway.udpRoute.rules }}
    {{- range $rule := .Values.gateway.udpRoute.rules }}
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
Extra UDPRoutes resource template.
Usage: {{- include "common.extraUdpRoutes" . }}
*/}}
{{- define "common.extraUdpRoutes" -}}
{{- if and .Values.gateway.udpRoute.enabled (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/UDPRoute") }}
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
