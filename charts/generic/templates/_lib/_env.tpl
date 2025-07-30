{{/*
Environment variables template
*/}}
{{- define "generic.envVars" -}}
{{- $envVars := .envVars -}}
{{- $root := .root -}}
{{- range $envVar := $envVars }}
{{- if and $envVar.name $envVar.value }}
- name: {{ $envVar.name }}
  value: {{ include "generic.tplValue" (dict "value" $envVar.value "context" $root) | quote }}
{{- else if and $envVar.name $envVar.valueFrom }}
- name: {{ $envVar.name }}
  valueFrom:
    {{- if $envVar.valueFrom.fieldRef }}
    fieldRef:
      fieldPath: {{ $envVar.valueFrom.fieldRef.fieldPath }}
      {{- if $envVar.valueFrom.fieldRef.apiVersion }}
      apiVersion: {{ $envVar.valueFrom.fieldRef.apiVersion }}
      {{- end }}
    {{- else if $envVar.valueFrom.resourceFieldRef }}
    resourceFieldRef:
      resource: {{ $envVar.valueFrom.resourceFieldRef.resource }}
      {{- if $envVar.valueFrom.resourceFieldRef.containerName }}
      containerName: {{ $envVar.valueFrom.resourceFieldRef.containerName }}
      {{- end }}
      {{- if $envVar.valueFrom.resourceFieldRef.divisor }}
      divisor: {{ $envVar.valueFrom.resourceFieldRef.divisor }}
      {{- end }}
    {{- else if $envVar.valueFrom.configMapKeyRef }}
    configMapKeyRef:
      name: {{ $envVar.valueFrom.configMapKeyRef.name }}
      key: {{ $envVar.valueFrom.configMapKeyRef.key }}
      {{- if hasKey $envVar.valueFrom.configMapKeyRef "optional" }}
      optional: {{ $envVar.valueFrom.configMapKeyRef.optional }}
      {{- end }}
    {{- else if $envVar.valueFrom.secretKeyRef }}
    secretKeyRef:
      name: {{ $envVar.valueFrom.secretKeyRef.name }}
      key: {{ $envVar.valueFrom.secretKeyRef.key }}
      {{- if hasKey $envVar.valueFrom.secretKeyRef "optional" }}
      optional: {{ $envVar.valueFrom.secretKeyRef.optional }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Common environment variables
*/}}
{{- define "generic.commonEnvVars" -}}
{{- $root := . -}}
{{- $commonEnv := list -}}
{{/* Add POD_NAME */}}
{{- $commonEnv = append $commonEnv (dict "name" "POD_NAME" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.name"))) -}}
{{/* Add POD_NAMESPACE */}}
{{- $commonEnv = append $commonEnv (dict "name" "POD_NAMESPACE" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.namespace"))) -}}
{{/* Add POD_IP */}}
{{- $commonEnv = append $commonEnv (dict "name" "POD_IP" "valueFrom" (dict "fieldRef" (dict "fieldPath" "status.podIP"))) -}}
{{/* Add NODE_NAME */}}
{{- $commonEnv = append $commonEnv (dict "name" "NODE_NAME" "valueFrom" (dict "fieldRef" (dict "fieldPath" "spec.nodeName"))) -}}
{{/* Add SERVICE_ACCOUNT */}}
{{- $commonEnv = append $commonEnv (dict "name" "SERVICE_ACCOUNT" "valueFrom" (dict "fieldRef" (dict "fieldPath" "spec.serviceAccountName"))) -}}
{{- include "generic.envVars" (dict "envVars" $commonEnv "root" $root) -}}
{{- end -}}

{{/*
Environment from sources (ConfigMaps and Secrets)
*/}}
{{- define "generic.envFrom" -}}
{{- $root := . -}}
{{- $envFromSources := list -}}
{{/* Main ConfigMap */}}
{{- if and .Values.configMap.enabled .Values.configMap.envFrom -}}
  {{- $envFromSources = append $envFromSources (dict "configMapRef" (dict "name" (include "generic.configMapName" .))) -}}
{{- end -}}
{{/* Main Secret */}}
{{- if and .Values.secret.enabled .Values.secret.envFrom -}}
  {{- $envFromSources = append $envFromSources (dict "secretRef" (dict "name" (include "generic.secretName" .))) -}}
{{- end -}}
{{/* Extra ConfigMaps */}}
{{- range $name, $config := .Values.extraConfigMaps -}}
  {{- if $config.envFrom -}}
    {{- $source := dict "configMapRef" (dict "name" $name) -}}
    {{- if $config.prefix -}}
      {{- $_ := set $source "prefix" $config.prefix -}}
    {{- end -}}
    {{- $envFromSources = append $envFromSources $source -}}
  {{- end -}}
{{- end -}}
{{/* Extra Secrets */}}
{{- range $name, $config := .Values.extraSecrets -}}
  {{- if $config.envFrom -}}
    {{- $source := dict "secretRef" (dict "name" $name) -}}
    {{- if $config.prefix -}}
      {{- $_ := set $source "prefix" $config.prefix -}}
    {{- end -}}
    {{- $envFromSources = append $envFromSources $source -}}
  {{- end -}}
{{- end -}}
{{/* External Secrets */}}
{{- range $name, $config := .Values.externalSecrets -}}
  {{- if and $config.enabled $config.envFrom -}}
    {{- $secretName := $name -}}
    {{- if and $config.target $config.target.name -}}
      {{- $secretName = $config.target.name -}}
    {{- end -}}
    {{- $source := dict "secretRef" (dict "name" $secretName) -}}
    {{- if $config.prefix -}}
      {{- $_ := set $source "prefix" $config.prefix -}}
    {{- end -}}
    {{- $envFromSources = append $envFromSources $source -}}
  {{- end -}}
{{- end -}}
{{/* Custom envFrom */}}
{{- with .Values.envFrom -}}
  {{- $envFromSources = concat $envFromSources . -}}
{{- end -}}
{{/* Extra envFrom */}}
{{- with .Values.extraEnvFrom -}}
  {{- $envFromSources = concat $envFromSources . -}}
{{- end -}}
{{/* Output */}}
{{- if $envFromSources -}}
envFrom:
  {{- toYaml $envFromSources | nindent 0 }}
{{- end -}}
{{- end -}}
