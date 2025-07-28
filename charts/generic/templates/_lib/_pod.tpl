{{/*
Pod template for generic workloads
*/}}
{{- define "generic.podTemplate" -}}
{{- $root := . -}}
metadata:
  labels:
    {{- include "generic.labels" . | nindent 4 }}
    {{- range $key, $value := .Values.podLabels }}
    {{ $key }}: {{ include "generic.tplValue" (dict "value" $value "context" $) | quote }}
    {{- end }}
  annotations:
    {{- include "generic.podAnnotations" . | nindent 4 }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.serviceAccount.enabled }}
  serviceAccountName: {{ include "generic.serviceAccountName" . }}
  {{- else if .Values.serviceAccount.name }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  {{- end }}
  {{- with .Values.hostAliases }}
  hostAliases:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.hostNetwork }}
  hostNetwork: true
  {{- end }}
  {{- if .Values.hostPID }}
  hostPID: true
  {{- end }}
  {{- if .Values.hostIPC }}
  hostIPC: true
  {{- end }}
  {{- with .Values.hostname }}
  hostname: {{ . }}
  {{- end }}
  {{- with .Values.dnsPolicy }}
  dnsPolicy: {{ . }}
  {{- end }}
  {{- with .Values.dnsConfig }}
  dnsConfig:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.priorityClassName }}
  priorityClassName: {{ . }}
  {{- end }}
  {{- with .Values.priority }}
  priority: {{ . }}
  {{- end }}
  {{- with .Values.runtimeClassName }}
  runtimeClassName: {{ . }}
  {{- end }}
  {{- with .Values.schedulerName }}
  schedulerName: {{ . }}
  {{- end }}
  {{- if .Values.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
  {{- end }}
  {{- with .Values.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.topologySpreadConstraints }}
  topologySpreadConstraints:
    {{- include "generic.topologySpreadConstraints" . | nindent 4 }}
  {{- end }}
  securityContext:
    {{- include "generic.podSecurityContext" (dict "securityContext" .Values.podSecurityContext "defaults" .Values.podSecurityContextDefaults) | nindent 4 }}
  {{- if or .Values.initContainers .Values.sidecarContainers }}
  initContainers:
    {{- range $container := .Values.initContainers }}
    {{- include "generic.container" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
    {{/* Native Kubernetes sidecar containers as init containers with restartPolicy: Always */}}
    {{- range $container := .Values.sidecarContainers }}
    {{- include "generic.sidecarContainer" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
  {{- end }}
  containers:
    {{- if .Values.containers }}
    {{- range $container := .Values.containers }}
    {{- include "generic.container" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
    {{- else }}
    {{/* Default single container configuration for backward compatibility */}}
    - name: {{ .Values.containerName | default "main" }}
      image: {{ include "generic.image" . }}
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      {{- with .Values.deployment.command }}
      command:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.deployment.args }}
      args:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or .Values.deployment.env .Values.commonEnvVars .Values.deployment.envFrom }}
      {{- if .Values.commonEnvVars }}
      env:
        {{- include "generic.commonEnvVars" . | nindent 8 }}
        {{- with .Values.deployment.env }}
        {{- include "generic.envVars" (dict "envVars" . "root" $root) | nindent 8 }}
        {{- end }}
      {{- else if .Values.deployment.env }}
      env:
        {{- include "generic.envVars" (dict "envVars" .Values.deployment.env "root" $root) | nindent 8 }}
      {{- end }}
      {{- include "generic.envFrom" . | nindent 6 }}
      {{- end }}
      {{- if .Values.containerPorts }}
      ports:
        {{- range .Values.containerPorts }}
        - name: {{ .name }}
          containerPort: {{ .containerPort }}
          protocol: {{ .protocol | default "TCP" }}
        {{- end }}
      {{- else if .Values.service.enabled }}
      ports:
        - name: http
          containerPort: {{ .Values.service.targetPort | default .Values.service.port | default 80 }}
          protocol: TCP
      {{- end }}
      {{- with .Values.deployment.livenessProbe }}
      livenessProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.deployment.readinessProbe }}
      readinessProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.deployment.startupProbe }}
      startupProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.deployment.resources }}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- include "generic.volumeMounts" (dict "container" .Values.deployment "root" $root) | nindent 6 }}
      {{- with .Values.deployment.lifecycle }}
      lifecycle:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- include "generic.containerSecurityContext" (dict "securityContext" .Values.deployment.securityContext "root" $root) | nindent 8 }}
    {{- end }}
  {{- include "generic.volumes" . | nindent 2 }}
  {{- with .Values.restartPolicy }}
  restartPolicy: {{ . }}
  {{- end }}
{{- end -}}

{{/*
Pod annotations including checksums
*/}}
{{- define "generic.podAnnotations" -}}
{{- $annotations := dict -}}
{{- if .Values.configMap.enabled -}}
  {{- $_ := set $annotations "checksum/config" (include (print .Template.BasePath "/core/configmap.yaml") . | sha256sum) -}}
{{- end -}}
{{- if .Values.secret.enabled -}}
  {{- $_ := set $annotations "checksum/secret" (include (print .Template.BasePath "/core/secret.yaml") . | sha256sum) -}}
{{- end -}}
{{- $securityAnnotations := include "generic.securityAnnotations" . -}}
{{- if $securityAnnotations -}}
  {{- $securityAnnotationsDict := $securityAnnotations | fromYaml -}}
  {{- $annotations = merge $annotations $securityAnnotationsDict -}}
{{- end -}}
{{- with .Values.podAnnotations -}}
  {{- $annotations = merge $annotations . -}}
{{- end -}}
{{- toYaml $annotations -}}
{{- end -}}

{{/*
Topology spread constraints with label selector
*/}}
{{- define "generic.topologySpreadConstraints" -}}
{{- range .Values.topologySpreadConstraints }}
- maxSkew: {{ .maxSkew | default 1 }}
  topologyKey: {{ .topologyKey | default "kubernetes.io/hostname" }}
  whenUnsatisfiable: {{ .whenUnsatisfiable | default "ScheduleAnyway" }}
  {{- if .labelSelector }}
  labelSelector:
    {{- toYaml .labelSelector | nindent 4 }}
  {{- else }}
  labelSelector:
    matchLabels:
      {{- include "generic.selectorLabels" $ | nindent 6 }}
  {{- end }}
  {{- with .minDomains }}
  minDomains: {{ . }}
  {{- end }}
  {{- with .nodeAffinityPolicy }}
  nodeAffinityPolicy: {{ . }}
  {{- end }}
  {{- with .nodeTaintsPolicy }}
  nodeTaintsPolicy: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Generic pod template that can be used for both main and extra deployments
Parameters:
- root: The root context
- deployment: The deployment configuration
- componentName: Optional component name for extra deployments
*/}}
{{- define "generic.deploymentPodTemplate" -}}
{{- $root := .root -}}
{{- $deployment := .deployment -}}
{{- $componentName := .componentName | default "" -}}
metadata:
  labels:
    {{- include "generic.labels" $root | nindent 4 }}
    {{- if $componentName }}
    app.kubernetes.io/component: {{ $componentName }}
    {{- end }}
    {{- with $deployment.podLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{- with $deployment.podAnnotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- if $deployment.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml $deployment.imagePullSecrets | nindent 4 }}
  {{- else if $root.Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml $root.Values.imagePullSecrets | nindent 4 }}
  {{- end }}
  {{- if $deployment.serviceAccountName }}
  serviceAccountName: {{ $deployment.serviceAccountName }}
  {{- else if $root.Values.serviceAccount.enabled }}
  serviceAccountName: {{ include "generic.serviceAccountName" $root }}
  {{- end }}
  {{- if $deployment.podSecurityContext }}
  securityContext:
    {{- toYaml $deployment.podSecurityContext | nindent 4 }}
  {{- else if $root.Values.podSecurityContext }}
  securityContext:
    {{- toYaml $root.Values.podSecurityContext | nindent 4 }}
  {{- end }}
  {{- if $deployment.nodeSelector }}
  nodeSelector:
    {{- toYaml $deployment.nodeSelector | nindent 4 }}
  {{- else if $root.Values.nodeSelector }}
  nodeSelector:
    {{- toYaml $root.Values.nodeSelector | nindent 4 }}
  {{- end }}
  {{- if $deployment.affinity }}
  affinity:
    {{- toYaml $deployment.affinity | nindent 4 }}
  {{- else if $root.Values.affinity }}
  affinity:
    {{- toYaml $root.Values.affinity | nindent 4 }}
  {{- end }}
  {{- if $deployment.tolerations }}
  tolerations:
    {{- toYaml $deployment.tolerations | nindent 4 }}
  {{- else if $root.Values.tolerations }}
  tolerations:
    {{- toYaml $root.Values.tolerations | nindent 4 }}
  {{- end }}
  {{- if or $deployment.topologySpreadConstraints $root.Values.topologySpreadConstraints }}
  topologySpreadConstraints:
    {{- $constraints := $deployment.topologySpreadConstraints | default $root.Values.topologySpreadConstraints }}
    {{- include "generic.topologySpreadConstraints" (dict "context" $root "componentName" $componentName "Values" (dict "topologySpreadConstraints" $constraints)) | nindent 4 }}
  {{- end }}
  {{- with $deployment.volumes }}
  volumes:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  containers:
    - name: {{ $componentName | default "main" }}
      image: {{ $deployment.image.repository }}:{{ $deployment.image.tag | default $root.Values.image.tag }}
      imagePullPolicy: {{ $deployment.image.pullPolicy | default $root.Values.image.pullPolicy }}
      {{- with $deployment.command }}
      command:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.args }}
      args:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.env }}
      env:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.envFrom }}
      envFrom:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.ports }}
      ports:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.livenessProbe }}
      livenessProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.readinessProbe }}
      readinessProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.startupProbe }}
      startupProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.resources }}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.volumeMounts }}
      volumeMounts:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if $deployment.securityContext }}
      securityContext:
        {{- toYaml $deployment.securityContext | nindent 8 }}
      {{- else if $root.Values.containerSecurityContext }}
      securityContext:
        {{- toYaml $root.Values.containerSecurityContext | nindent 8 }}
      {{- end }}
{{- end -}}
