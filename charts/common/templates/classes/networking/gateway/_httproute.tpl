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
  {{- if .Values.gateway.httpRoute.parentRefs }}
  parentRefs:
    {{- range $parentRef := .Values.gateway.httpRoute.parentRefs }}
    - group: {{ $parentRef.group | default "gateway.networking.k8s.io" }}
      kind: {{ $parentRef.kind | default "Gateway" }}
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
        {{- range $filter := . }}
        - type: {{ $filter.type }}
          {{- if eq $filter.type "RequestHeaderModifier" }}
          {{- with $filter.requestHeaderModifier }}
          requestHeaderModifier:
            {{- with .set }}
            set:
              {{- range $header := . }}
              - name: {{ $header.name }}
                value: {{ $header.value }}
              {{- end }}
            {{- end }}
            {{- with .add }}
            add:
              {{- range $header := . }}
              - name: {{ $header.name }}
                value: {{ $header.value }}
              {{- end }}
            {{- end }}
            {{- with .remove }}
            remove:
              {{- toYaml . | nindent 14 }}
            {{- end }}
          {{- end }}
          {{- end }}
          {{- if eq $filter.type "ResponseHeaderModifier" }}
          {{- with $filter.responseHeaderModifier }}
          responseHeaderModifier:
            {{- with .set }}
            set:
              {{- range $header := . }}
              - name: {{ $header.name }}
                value: {{ $header.value }}
              {{- end }}
            {{- end }}
            {{- with .add }}
            add:
              {{- range $header := . }}
              - name: {{ $header.name }}
                value: {{ $header.value }}
              {{- end }}
            {{- end }}
            {{- with .remove }}
            remove:
              {{- toYaml . | nindent 14 }}
            {{- end }}
          {{- end }}
          {{- end }}
          {{- if eq $filter.type "RequestMirror" }}
          {{- with $filter.requestMirror }}
          requestMirror:
            backendRef:
              {{- if .backendRef.group }}
              group: {{ .backendRef.group }}
              {{- end }}
              {{- if .backendRef.kind }}
              kind: {{ .backendRef.kind }}
              {{- end }}
              {{- if .backendRef.namespace }}
              namespace: {{ .backendRef.namespace }}
              {{- end }}
              name: {{ .backendRef.name }}
              {{- with .backendRef.port }}
              port: {{ . }}
              {{- end }}
          {{- end }}
          {{- end }}
          {{- if eq $filter.type "RequestRedirect" }}
          {{- with $filter.requestRedirect }}
          requestRedirect:
            {{- with .scheme }}
            scheme: {{ . }}
            {{- end }}
            {{- with .hostname }}
            hostname: {{ . }}
            {{- end }}
            {{- with .path }}
            path:
              {{- if .type }}
              type: {{ .type }}
              {{- end }}
              {{- if .replaceFullPath }}
              replaceFullPath: {{ .replaceFullPath }}
              {{- end }}
              {{- if .replacePrefixMatch }}
              replacePrefixMatch: {{ .replacePrefixMatch }}
              {{- end }}
            {{- end }}
            {{- with .port }}
            port: {{ . }}
            {{- end }}
            {{- with .statusCode }}
            statusCode: {{ . }}
            {{- end }}
          {{- end }}
          {{- end }}
          {{- if eq $filter.type "URLRewrite" }}
          {{- with $filter.urlRewrite }}
          urlRewrite:
            {{- with .hostname }}
            hostname: {{ . }}
            {{- end }}
            {{- with .path }}
            path:
              {{- if .type }}
              type: {{ .type }}
              {{- end }}
              {{- if .replaceFullPath }}
              replaceFullPath: {{ .replaceFullPath }}
              {{- end }}
              {{- if .replacePrefixMatch }}
              replacePrefixMatch: {{ .replacePrefixMatch }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- end }}
          {{- if eq $filter.type "ExtensionRef" }}
          {{- with $filter.extensionRef }}
          extensionRef:
            group: {{ .group }}
            kind: {{ .kind }}
            name: {{ .name }}
          {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
      backendRefs:
        {{- if $rule.backendRefs }}
        {{- range $backendRef := $rule.backendRefs }}
        - group: {{ $backendRef.group | default "" | quote }}
          kind: {{ $backendRef.kind | default "Service" }}
          {{- if $backendRef.namespace }}
          namespace: {{ $backendRef.namespace }}
          {{- end }}
          name: {{ $backendRef.name }}
          {{- with $backendRef.port }}
          port: {{ . }}
          {{- end }}
          weight: {{ $backendRef.weight | default 1 }}
          {{- with $backendRef.filters }}
          filters:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- else }}
        - group: ""
          kind: Service
          name: {{ include "common.fullname" $ }}
          port: {{ include "common.servicePort" $ }}
          weight: 1
        {{- end }}
    {{- end }}
    {{- else }}
    # Default rule
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - group: ""
          kind: Service
          name: {{ include "common.fullname" . }}
          port: {{ include "common.servicePort" . }}
          weight: 1
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
