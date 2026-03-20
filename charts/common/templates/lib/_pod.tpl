{{/*
Unified pod template for all workload types
Parameters:
- root: The root context (defaults to .)
- config: Optional deployment/workload configuration
- componentName: Optional component name for extra deployments
- defaultRestartPolicy: Optional default restartPolicy (e.g., "OnFailure" for jobs, "Never" for hooks)
*/}}
{{- define "common.podTemplate" -}}
{{- $root := .root | default . -}}
{{- $config := .config | default dict -}}
{{- $componentName := .componentName | default "main" -}}
{{- $defaultRestartPolicy := .defaultRestartPolicy | default "" -}}
{{- $deployment := $root.Values -}}
metadata:
  labels:
    {{- $podLabels := $config.podLabels | default ($config.pod).labels | default $deployment.pod.labels -}}
    {{- $podLabels = merge (dict "app.kubernetes.io/component" $componentName) $podLabels -}}
    {{- include "common.labels" (dict "context" $root "labels" $podLabels "pod" true) | nindent 4 }}
  annotations:
    {{- $podAnnotations := $config.podAnnotations | default ($config.pod).annotations | default $deployment.pod.annotations -}}
    {{- include "common.podAnnotations" (dict "root" $root "annotations" $podAnnotations) | nindent 4 }}
spec:
  {{- $imagePullSecrets := $config.imagePullSecrets | default $deployment.imagePullSecrets -}}
  {{- with $imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $config.serviceAccountName }}
  serviceAccountName: {{ $config.serviceAccountName }}
  {{- else if $root.Values.serviceAccount.enabled }}
  serviceAccountName: {{ include "common.serviceAccountName" $root }}
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
    {{- include "common.topologySpreadConstraints" (dict "context" $root "componentName" $componentName "Values" (dict "topologySpreadConstraints" $topologySpreadConstraints)) | nindent 4 }}
  {{- end }}
  securityContext:
    {{- $podSecurityContext := $config.podSecurityContext | default ($config.pod).securityContext | default $deployment.pod.securityContext | default $root.Values.security.defaultPodSecurityContext -}}
    {{- include "common.podSecurityContext" (dict "securityContext" $podSecurityContext "defaults" $root.Values.security.defaultPodSecurityContext) | nindent 4 }}
  {{- /* Pod-level resources (Kubernetes 1.34+ where PodLevelResources is enabled by default) */ -}}
  {{- $podResources := $config.podResources | default $deployment.resources -}}
  {{- if and $podResources (not (empty $podResources)) (semverCompare ">=1.34-0" $root.Capabilities.KubeVersion.Version) }}
  resources:
    {{- toYaml $podResources | nindent 4 }}
  {{- end -}}
  {{- /* For extraDeployments, only inherit root initContainers/sidecarContainers if inheritInitContainers is true */ -}}
  {{- $inheritInit := $config.inheritInitContainers | default false -}}
  {{- $initContainers := $config.initContainers | default (ternary $deployment.initContainers list (or (empty $config) $inheritInit)) -}}
  {{- $sidecarContainers := $config.sidecarContainers | default (ternary $deployment.sidecarContainers list (or (empty $config) $inheritInit)) -}}
  {{- if or $initContainers $sidecarContainers }}
  initContainers:
    {{- range $container := $initContainers }}
    {{- include "common.container" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
    {{/* Native Kubernetes sidecar containers as init containers with restartPolicy: Always */}}
    {{- range $container := $sidecarContainers }}
    {{- include "common.sidecarContainer" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
  {{- end }}
  containers:
    {{- if and (not (empty $config)) $config }}
    {{/* Handle extra deployments / component containers - prefer config.name for container name */}}
    {{- $resolvedContainerName := $config.name | default ($componentName | default "main") -}}
    {{- include "common.container" (dict "container" $config "root" $root "containerName" $resolvedContainerName) | nindent 4 }}
    {{- else if $deployment.extraContainers }}
    {{- range $container := $deployment.extraContainers }}
    {{- include "common.container" (dict "container" $container "root" $root) | nindent 4 }}
    {{- end }}
    {{- else }}
    {{/* Default single container configuration */}}
    {{- include "common.container" (dict "container" $deployment "root" $root "mainContainer" true) | nindent 4 }}
    {{- end }}
  {{- with $config.volumes }}
  volumes:
    {{- toYaml . | nindent 4 }}
  {{- else }}
  {{- include "common.volumes" $root | nindent 2 }}
  {{- end }}
  {{- $restartPolicy := $config.restartPolicy | default ($config.pod).restartPolicy | default $deployment.pod.restartPolicy | default $defaultRestartPolicy -}}
  {{- with $restartPolicy }}
  restartPolicy: {{ . }}
  {{- end }}
{{- end -}}

{{/*
Pod annotations including checksums
*/}}
{{- define "common.podAnnotations" -}}
{{- $root := .root | default . -}}
{{- $extraAnnotations := .annotations | default dict -}}
{{- $annotations := dict -}}
{{- if $root.Values.configMap.enabled -}}
  {{- $_ := set $annotations "checksum/config" (include "common.configmap" $root | sha256sum) -}}
{{- end -}}
{{- if $root.Values.secret.enabled -}}
  {{- $_ := set $annotations "checksum/secret" (include "common.secret" $root | sha256sum) -}}
{{- end -}}
{{- $securityAnnotations := include "common.securityAnnotations" $root -}}
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
Process topology spread constraints to add labelSelector if not specified
Usage:
  {{- include "common.topologySpreadConstraints" . }}
Or with component name:
  {{- include "common.topologySpreadConstraints" (dict "context" . "componentName" "worker") }}
*/}}
{{- define "common.topologySpreadConstraints" -}}
{{- $context := .context | default . -}}
{{- $componentName := .componentName | default "" -}}
{{- $constraints := .Values.topologySpreadConstraints | default $context.Values.topologySpreadConstraints -}}
{{- $selectorLabels := include "common.selectorLabels" $context | fromYaml -}}
{{- if $componentName -}}
  {{- $selectorLabels = merge $selectorLabels (dict "app.kubernetes.io/component" $componentName) -}}
{{- end -}}
{{- range $constraint := $constraints }}
- maxSkew: {{ $constraint.maxSkew }}
  topologyKey: {{ $constraint.topologyKey }}
  whenUnsatisfiable: {{ $constraint.whenUnsatisfiable }}
  {{- if $constraint.labelSelector }}
  labelSelector:
    {{- toYaml $constraint.labelSelector | nindent 4 }}
  {{- else }}
  labelSelector:
    matchLabels:
      {{- toYaml $selectorLabels | nindent 6 }}
  {{- end }}
  {{- if $constraint.minDomains }}
  minDomains: {{ $constraint.minDomains }}
  {{- end }}
  {{- if $constraint.nodeAffinityPolicy }}
  nodeAffinityPolicy: {{ $constraint.nodeAffinityPolicy }}
  {{- end }}
  {{- if $constraint.nodeTaintsPolicy }}
  nodeTaintsPolicy: {{ $constraint.nodeTaintsPolicy }}
  {{- end }}
  {{- if $constraint.matchLabelKeys }}
  matchLabelKeys:
    {{- toYaml $constraint.matchLabelKeys | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end }}

{{/*
Get the service port
*/}}
{{- define "common.servicePort" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).port }}
{{- else if .Values.ports }}
{{- (index .Values.ports 0).port | default (index .Values.ports 0).containerPort }}
{{- else }}
{{- 80 }}
{{- end }}
{{- end }}

{{/*
Get the service target port
*/}}
{{- define "common.serviceTargetPort" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).targetPort }}
{{- else if .Values.ports }}
{{- (index .Values.ports 0).containerPort }}
{{- else }}
{{- 80 }}
{{- end }}
{{- end }}

{{/*
Get the service port name
*/}}
{{- define "common.servicePortName" -}}
{{- if .Values.service.ports }}
{{- (index .Values.service.ports 0).name | default "http" }}
{{- else if .Values.ports }}
{{- (index .Values.ports 0).name | default "http" }}
{{- else }}
{{- "http" }}
{{- end }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "common.validateValues" -}}
{{- $workloadType := .Values.workload.type | default "deployment" -}}
{{- $hasWorkload := or (eq $workloadType "deployment") (eq $workloadType "statefulset") (eq $workloadType "daemonset") -}}
{{- if $hasWorkload }}
{{- if not .Values.image.repository }}
{{- fail "image.repository is required when a workload is enabled" }}
{{- end }}
{{- end }}
{{- end }}
