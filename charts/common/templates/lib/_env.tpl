{{/*
Environment variables template
*/}}
{{- define "common.envVars" -}}
{{- $envVars := .envVars -}}
{{- $root := .root -}}
{{- range $envVar := $envVars }}
{{- if and $envVar.name $envVar.value }}
- name: {{ $envVar.name }}
  value: {{ include "common.tplValue" (dict "value" $envVar.value "context" $root) | quote }}
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
Common environment variables injected into all containers when commonEnvVars is enabled.
Includes: runtime defaults, Kubernetes downward API, and Datadog unified service tagging.
*/}}
{{- define "common.commonEnvVars" -}}
{{- $root := . -}}
{{- $commonEnv := list -}}
{{/* Runtime defaults from values */}}
{{- range $key, $value := $root.Values.envDefaults }}
{{- if not (kindIs "invalid" $value) }}
{{- $commonEnv = append $commonEnv (dict "name" $key "value" ($value | toString)) -}}
{{- end }}
{{- end -}}
{{- if $root.Values.ports -}}
  {{- $firstPort := index $root.Values.ports 0 -}}
  {{- $commonEnv = append $commonEnv (dict "name" "PORT" "value" ($firstPort.containerPort | toString)) -}}
{{- else if $root.Values.port -}}
  {{- $commonEnv = append $commonEnv (dict "name" "PORT" "value" ($root.Values.port | toString)) -}}
{{- end -}}
{{/* Kubernetes downward API */}}
{{- $commonEnv = append $commonEnv (dict "name" "POD_NAME" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.name"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "POD_NAMESPACE" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.namespace"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "POD_IP" "valueFrom" (dict "fieldRef" (dict "fieldPath" "status.podIP"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "NODE_NAME" "valueFrom" (dict "fieldRef" (dict "fieldPath" "spec.nodeName"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "SERVICE_ACCOUNT" "valueFrom" (dict "fieldRef" (dict "fieldPath" "spec.serviceAccountName"))) -}}
{{/* Datadog unified service tagging (from pod labels via downward API) */}}
{{- if $root.Values.datadog.enabled -}}
{{- $commonEnv = append $commonEnv (dict "name" "DD_SERVICE" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.labels['tags.datadoghq.com/service']"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "DD_ENV" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.labels['tags.datadoghq.com/env']"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "DD_VERSION" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.labels['tags.datadoghq.com/version']"))) -}}
{{/* Datadog agent connection */}}
{{- $commonEnv = append $commonEnv (dict "name" "DD_AGENT_HOST" "valueFrom" (dict "fieldRef" (dict "fieldPath" "status.hostIP"))) -}}
{{- $commonEnv = append $commonEnv (dict "name" "DD_ENTITY_ID" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.uid"))) -}}
{{- end -}}
{{- include "common.envVars" (dict "envVars" $commonEnv "root" $root) -}}
{{- end -}}

{{/*
Environment from sources (ConfigMaps and Secrets)
*/}}
{{- define "common.envFrom" -}}
{{- $root := . -}}
{{- $envFromSources := list -}}
{{/* Main ConfigMap */}}
{{- if and .Values.configMap.enabled .Values.configMap.envFrom -}}
  {{- $envFromSources = append $envFromSources (dict "configMapRef" (dict "name" (include "common.configMapName" .))) -}}
{{- end -}}
{{/* Main Secret */}}
{{- if and .Values.secret.enabled .Values.secret.envFrom -}}
  {{- $envFromSources = append $envFromSources (dict "secretRef" (dict "name" (include "common.secretName" .))) -}}
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
