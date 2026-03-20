{{/*
ExternalSecret resource template.
Usage: {{- include "common.externalSecrets" . }}
*/}}
{{- define "common.externalSecrets" -}}
{{- if .Values.externalSecrets }}
{{- $apiVersion := "" }}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1/ExternalSecret" }}
  {{- $apiVersion = "external-secrets.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "external-secrets.io/v1beta1/ExternalSecret" }}
  {{- $apiVersion = "external-secrets.io/v1beta1" }}
{{- end }}
{{- if $apiVersion }}
{{- range $name, $externalSecret := .Values.externalSecrets }}
{{- if $externalSecret.enabled }}
---
apiVersion: {{ $apiVersion }}
kind: ExternalSecret
metadata:
  name: {{ $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- include "common.labels" (dict "context" $ "labels" $externalSecret.labels) | nindent 4 }}
  {{- if or $externalSecret.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $externalSecret.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with $externalSecret.refreshInterval }}
  refreshInterval: {{ . }}
  {{- end }}

  {{- if $externalSecret.secretStoreRef }}
  secretStoreRef:
    name: {{ $externalSecret.secretStoreRef.name }}
    {{- with $externalSecret.secretStoreRef.kind }}
    kind: {{ . }}
    {{- end }}
  {{- end }}

  {{- if $externalSecret.target }}
  target:
    name: {{ $externalSecret.target.name | default $name }}
    {{- with $externalSecret.target.creationPolicy }}
    creationPolicy: {{ . }}
    {{- end }}
    {{- with $externalSecret.target.deletionPolicy }}
    deletionPolicy: {{ . }}
    {{- end }}
    {{- with $externalSecret.target.template }}
    template:
      {{- with .type }}
      type: {{ . }}
      {{- end }}
      {{- with .engineVersion }}
      engineVersion: {{ . }}
      {{- end }}
      {{- with .metadata }}
      metadata:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .data }}
      data:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- if $externalSecret.data }}
  data:
    {{- range $externalSecret.data }}
    - secretKey: {{ .secretKey }}
      remoteRef:
        conversionStrategy: {{ .remoteRef.conversionStrategy | default "Default" }}
        decodingStrategy: {{ .remoteRef.decodingStrategy | default "None" }}
        key: {{ .remoteRef.key }}
        {{- with .remoteRef.property }}
        property: {{ . }}
        {{- end }}
        {{- with .remoteRef.version }}
        version: {{ . }}
        {{- end }}
        metadataPolicy: {{ .remoteRef.metadataPolicy | default "None" }}
    {{- end }}
  {{- end }}

  {{- if $externalSecret.dataFrom }}
  dataFrom:
    {{- range $externalSecret.dataFrom }}
    - {{- if .extract }}
      extract:
        conversionStrategy: {{ .extract.conversionStrategy | default "Default" }}
        decodingStrategy: {{ .extract.decodingStrategy | default "None" }}
        key: {{ .extract.key }}
        {{- with .extract.property }}
        property: {{ . }}
        {{- end }}
        {{- with .extract.version }}
        version: {{ . }}
        {{- end }}
        metadataPolicy: {{ .extract.metadataPolicy | default "None" }}
      {{- end }}
      {{- if .find }}
      find:
        conversionStrategy: {{ .find.conversionStrategy | default "Default" }}
        decodingStrategy: {{ .find.decodingStrategy | default "None" }}
        {{- with .find.path }}
        path: {{ . }}
        {{- end }}
        {{- with .find.name }}
        name:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .find.tags }}
        tags:
          {{- toYaml . | nindent 10 }}
        {{- end }}
      {{- end }}
      {{- if .rewrite }}
      rewrite:
        {{- toYaml .rewrite | nindent 8 }}
      {{- end }}
      {{- if .sourceRef }}
      sourceRef:
        {{- toYaml .sourceRef | nindent 8 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
