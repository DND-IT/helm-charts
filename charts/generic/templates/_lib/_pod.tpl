{{/*
Unified pod template for all workload types
Parameters:
- root: The root context (defaults to .)
- config: Optional deployment/workload configuration
- componentName: Optional component name for extra deployments
*/}}
{{- define "generic.podTemplate" -}}
{{- $root := .root | default . -}}
{{- $config := .config | default dict -}}
{{- $componentName := .componentName | default "" -}}
{{- $deployment := $root.Values -}}
metadata:
  labels:
    {{- $podLabels := $config.podLabels | default ($config.pod).labels | default $deployment.pod.labels -}}
    {{- if $componentName -}}
      {{- $podLabels = merge (dict "app.kubernetes.io/component" $componentName) $podLabels -}}
    {{- end -}}
    {{- include "generic.labels" (dict "context" $root "labels" $podLabels) | nindent 4 }}
  annotations:
    {{- $podAnnotations := $config.podAnnotations | default ($config.pod).annotations | default $deployment.pod.annotations -}}
    {{- include "generic.podAnnotations" (dict "root" $root "annotations" $podAnnotations) | nindent 4 }}
spec:
  {{- $imagePullSecrets := $config.imagePullSecrets | default $deployment.imagePullSecrets -}}
  {{- with $imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $config.serviceAccountName }}
  serviceAccountName: {{ $config.serviceAccountName }}
  {{- else if $root.Values.serviceAccount.enabled }}
  serviceAccountName: {{ include "generic.serviceAccountName" $root }}
  {{- else if $root.Values.serviceAccount.name }}
  serviceAccountName: {{ $root.Values.serviceAccount.name }}
  {{- end }}
  {{- with $config.hostAliases | default ($config.pod).hostAliases | default $deployment.pod.hostAliases }}
  hostAliases:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $config.hostNetwork | default ($config.pod).hostNetwork | default $deployment.pod.hostNetwork }}
  hostNetwork: true
  {{- end }}
  {{- if $config.hostPID | default ($config.pod).hostPID | default $deployment.pod.hostPID }}
  hostPID: true
  {{- end }}
  {{- if $config.hostIPC | default ($config.pod).hostIPC | default $deployment.pod.hostIPC }}
  hostIPC: true
  {{- end }}
  {{- with $config.hostname | default ($config.pod).hostname | default $deployment.pod.hostname }}
  hostname: {{ . }}
  {{- end }}
  {{- with $config.dnsPolicy | default ($config.pod).dnsPolicy | default $deployment.pod.dnsPolicy }}
  dnsPolicy: {{ . }}
  {{- end }}
  {{- with $config.dnsConfig | default ($config.pod).dnsConfig | default $deployment.pod.dnsConfig }}
  dnsConfig:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $config.priorityClassName | default ($config.pod).priorityClassName | default $deployment.pod.priorityClassName }}
  priorityClassName: {{ . }}
  {{- end }}
  {{- with $config.priority | default ($config.pod).priority | default $deployment.pod.priority }}
  priority: {{ . }}
  {{- end }}
  {{- with $config.runtimeClassName | default ($config.pod).runtimeClassName | default $deployment.pod.runtimeClassName }}
  runtimeClassName: {{ . }}
  {{- end }}
  {{- with $config.schedulerName | default ($config.pod).schedulerName | default $deployment.pod.schedulerName }}
  schedulerName: {{ . }}
  {{- end }}
  {{- $terminationGracePeriodSeconds := $config.terminationGracePeriodSeconds | default ($config.pod).terminationGracePeriodSeconds | default $deployment.pod.terminationGracePeriodSeconds -}}
  {{- if $terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ $terminationGracePeriodSeconds }}
  {{- end }}
  {{- with $config.activeDeadlineSeconds | default ($config.pod).activeDeadlineSeconds | default $deployment.pod.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with $config.nodeSelector | default ($config.scheduling).nodeSelector | default $deployment.scheduling.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $config.affinity | default ($config.scheduling).affinity | default $deployment.scheduling.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $config.tolerations | default ($config.scheduling).tolerations | default $deployment.scheduling.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- $topologySpreadConstraints := $config.topologySpreadConstraints | default ($config.scheduling).topologySpreadConstraints | default $deployment.scheduling.topologySpreadConstraints -}}
  {{- if $topologySpreadConstraints }}
  topologySpreadConstraints:
    {{- include "generic.topologySpreadConstraints" (dict "context" $root "componentName" $componentName "Values" (dict "topologySpreadConstraints" $topologySpreadConstraints)) | nindent 4 }}
  {{- end }}
  securityContext:
    {{- $podSecurityContext := $config.podSecurityContext | default ($config.pod).securityContext | default $deployment.pod.securityContext | default $root.Values.security.defaultPodSecurityContext -}}
    {{- include "generic.podSecurityContext" (dict "securityContext" $podSecurityContext "defaults" $root.Values.security.defaultPodSecurityContext) | nindent 4 }}
  {{- $initContainers := $config.initContainers | default $deployment.initContainers -}}
  {{- $sidecarContainers := $config.sidecarContainers | default $deployment.sidecarContainers -}}
  {{- if or $initContainers $sidecarContainers }}
  initContainers:
    {{- range $container := $initContainers }}
    {{- include "generic.container" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
    {{/* Native Kubernetes sidecar containers as init containers with restartPolicy: Always */}}
    {{- range $container := $sidecarContainers }}
    {{- include "generic.sidecarContainer" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
  {{- end }}
  containers:
    {{- if $config }}
    {{/* Handle extra deployments */}}
    - name: {{ $componentName | default "main" }}
      image: {{ include "generic.image" (dict "image" $config.image "context" $root) }}
      imagePullPolicy: {{ $config.image.pullPolicy | default $root.Values.image.pullPolicy }}
      {{- with $config.command }}
      command:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.args }}
      args:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.env }}
      env:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.envFrom }}
      envFrom:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.ports }}
      ports:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.livenessProbe }}
      livenessProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.readinessProbe }}
      readinessProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.startupProbe }}
      startupProbe:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.resources }}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.volumeMounts }}
      volumeMounts:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- $containerSecurityContext := $config.securityContext | default $root.Values.containerSecurityContext -}}
        {{- if $containerSecurityContext }}
        {{- toYaml $containerSecurityContext | nindent 8 }}
        {{- else }}
        {{- include "generic.containerSecurityContext" (dict "securityContext" nil "root" $root) | nindent 8 }}
        {{- end }}
    {{- else if $deployment.extraContainers }}
    {{- range $container := $deployment.extraContainers }}
    {{- include "generic.container" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
    {{- else }}
    {{/* Default single container configuration */}}
    {{- $imageConfig := $config.image | default $deployment.image -}}
    - name: main
      image: {{ include "generic.image" (dict "image" $imageConfig "context" $root) }}
      imagePullPolicy: {{ $imageConfig.pullPolicy }}
      {{- with $deployment.command }}
      command:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $deployment.args }}
      args:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or $deployment.env $deployment.commonEnvVars }}
      {{- if $deployment.commonEnvVars }}
      env:
        {{- include "generic.commonEnvVars" $root | nindent 8 }}
        {{- with $deployment.env }}
        {{- include "generic.envVars" (dict "envVars" . "root" $root) | nindent 8 }}
        {{- end }}
      {{- else if $deployment.env }}
      env:
        {{- include "generic.envVars" (dict "envVars" $deployment.env "root" $root) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- include "generic.envFrom" $root | nindent 6 }}
      {{- if $deployment.ports }}
      ports:
        {{- range $deployment.ports }}
        - name: {{ .name }}
          containerPort: {{ .containerPort }}
          protocol: {{ .protocol | default "TCP" }}
        {{- end }}
      {{- else if $root.Values.service.enabled }}
      ports:
        - name: http
          containerPort: {{ $root.Values.service.targetPort | default $root.Values.service.port | default 80 }}
          protocol: TCP
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
      {{- include "generic.volumeMounts" (dict "container" $deployment "root" $root) | nindent 6 }}
      {{- with $deployment.lifecycle }}
      lifecycle:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- include "generic.containerSecurityContext" (dict "securityContext" $deployment.securityContext "root" $root) | nindent 8 }}
    {{- end }}
  {{- with $config.volumes }}
  volumes:
    {{- toYaml . | nindent 4 }}
  {{- else }}
  {{- include "generic.volumes" $root | nindent 2 }}
  {{- end }}
  {{- with $config.restartPolicy | default ($config.pod).restartPolicy | default $deployment.pod.restartPolicy }}
  restartPolicy: {{ . }}
  {{- end }}
{{- end -}}

{{/*
Pod annotations including checksums
*/}}
{{- define "generic.podAnnotations" -}}
{{- $root := .root | default . -}}
{{- $extraAnnotations := .annotations | default dict -}}
{{- $annotations := dict -}}
{{- if $root.Values.configMap.enabled -}}
  {{- $_ := set $annotations "checksum/config" (include (print $root.Template.BasePath "/configmap.yaml") $root | sha256sum) -}}
{{- end -}}
{{- if $root.Values.secret.enabled -}}
  {{- $_ := set $annotations "checksum/secret" (include (print $root.Template.BasePath "/secret.yaml") $root | sha256sum) -}}
{{- end -}}
{{- $securityAnnotations := include "generic.securityAnnotations" $root -}}
{{- if $securityAnnotations -}}
  {{- $securityAnnotationsDict := $securityAnnotations | fromYaml -}}
  {{- $annotations = merge $annotations $securityAnnotationsDict -}}
{{- end -}}
{{- with $root.Values.commonAnnotations -}}
  {{- $annotations = merge $annotations . -}}
{{- end -}}
{{- with $root.Values.podAnnotations -}}
  {{- $annotations = merge $annotations . -}}
{{- end -}}
{{- with $extraAnnotations -}}
  {{- $annotations = merge $annotations . -}}
{{- end -}}
{{- toYaml $annotations -}}
{{- end -}}

{{/*
Topology spread constraints with label selector
*/}}
{{- define "generic.topologySpreadConstraints" -}}
{{- $context := .context -}}
{{- $componentName := .componentName | default "" -}}
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
      {{- include "generic.selectorLabels" $context | nindent 6 }}
      {{- if $componentName }}
      app.kubernetes.io/component: {{ $componentName }}
      {{- end }}
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
