{{/*
Gateway API shared helpers for route templates.
*/}}

{{/*
Render parentRefs for any Gateway API route type.
Parameters:
- parentRefs: list of parentRef objects
Usage: {{- include "common.gatewayParentRefs" $parentRefsList }}
*/}}
{{- define "common.gatewayParentRefs" -}}
{{- range $parentRef := . }}
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
{{- end -}}

{{/*
Render a single backendRef for any Gateway API route type.
Parameters:
- backendRef: A backendRef object
Usage: {{- include "common.gatewayBackendRef" $backendRef }}
*/}}
{{- define "common.gatewayBackendRef" -}}
{{- if .group }}
group: {{ .group }}
{{- end }}
{{- if .kind }}
kind: {{ .kind }}
{{- end }}
{{- if .namespace }}
namespace: {{ .namespace }}
{{- end }}
name: {{ .name }}
{{- with .port }}
port: {{ . }}
{{- end }}
{{- with .weight }}
weight: {{ . }}
{{- end }}
{{- with .filters }}
filters:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Render filters for HTTPRoute and GRPCRoute rules.
Parameters:
- filters: list of filter objects
Usage: {{- include "common.gatewayFilters" $rule.filters }}
*/}}
{{- define "common.gatewayFilters" -}}
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
      {{- toYaml . | nindent 6 }}
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
      {{- toYaml . | nindent 6 }}
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
{{- end -}}
