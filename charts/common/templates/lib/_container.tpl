{{/*
Container template for workloads
Parameters:
- container: Container configuration (required)
- root: Root context (required)
- mainContainer: If true, enables main container features: commonEnvVars merging,
    envFrom helper, service port fallback, volumeMounts helper (optional, default false)
- restartPolicy: If set, renders restartPolicy field on the container (for native sidecars) (optional)
- containerName: Override container name (optional, defaults to container.name or "main")
*/}}
{{- define "common.container" -}}
{{- $container := .container -}}
{{- $root := .root -}}
{{- $mainContainer := .mainContainer | default false -}}
{{- $containerRestartPolicy := .restartPolicy | default "" -}}
{{- $containerName := .containerName | default ($container.name) | default "main" -}}
{{- $imagePullPolicy := $container.imagePullPolicy -}}
{{- if and (not $imagePullPolicy) $container.image (kindIs "map" $container.image) -}}
  {{- $imagePullPolicy = $container.image.pullPolicy -}}
{{- end -}}
{{- $imagePullPolicy = $imagePullPolicy | default $root.Values.image.pullPolicy | default "IfNotPresent" -}}
- name: {{ $containerName }}
  image: {{ include "common.containerImage" (dict "container" $container "root" $root) }}
  imagePullPolicy: {{ $imagePullPolicy }}
  {{- if $containerRestartPolicy }}
  restartPolicy: {{ $containerRestartPolicy }}
  {{- end }}
  {{- with $container.command }}
  command:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.args }}
  args:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $mainContainer }}
  {{/* Main container: merge commonEnvVars, use envFrom/volumeMounts helpers */}}
  {{- if or $container.env $container.commonEnvVars }}
  {{- if $container.commonEnvVars }}
  env:
    {{- include "common.commonEnvVars" $root | nindent 4 }}
    {{- with $container.env }}
    {{- include "common.envVars" (dict "envVars" . "root" $root) | nindent 4 }}
    {{- end }}
  {{- else if $container.env }}
  env:
    {{- include "common.envVars" (dict "envVars" $container.env "root" $root) | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- include "common.envFrom" $root | nindent 2 }}
  {{- if $container.ports }}
  ports:
    {{- range $container.ports }}
    - name: {{ .name }}
      containerPort: {{ .containerPort }}
      protocol: {{ .protocol | default "TCP" }}
    {{- end }}
  {{- else if $root.Values.port }}
  ports:
    - name: http
      containerPort: {{ $root.Values.port }}
      protocol: TCP
  {{- else if $root.Values.service.enabled }}
  ports:
    - name: http
      containerPort: {{ $root.Values.service.targetPort | default $root.Values.service.port | default 80 }}
      protocol: TCP
  {{- end }}
  {{- else }}
  {{/* Non-main container: simple env/envFrom/ports */}}
  {{- if or $container.env $container.envFrom }}
  {{- with $container.env }}
  env:
    {{- include "common.envVars" (dict "envVars" . "root" $root) | nindent 4 }}
  {{- end }}
  {{- with $container.envFrom }}
  envFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- with $container.ports }}
  ports:
    {{- range . }}
    - name: {{ .name }}
      containerPort: {{ .containerPort }}
      protocol: {{ .protocol | default "TCP" }}
    {{- end }}
  {{- end }}
  {{- end }}
  {{- with $container.livenessProbe }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.readinessProbe }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.startupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $mainContainer }}
  {{- /* container.resources always takes precedence; top-level resources falls back to container level on K8s < 1.34 */ -}}
  {{- $explicitContainerResources := ($container.container).resources -}}
  {{- $topLevelResources := $container.resources -}}
  {{- $useContainerLevel := or $explicitContainerResources (and $topLevelResources (not (semverCompare ">=1.34-0" $root.Capabilities.KubeVersion.Version))) -}}
  {{- $mainResources := $explicitContainerResources | default $topLevelResources -}}
  {{- if and $useContainerLevel $mainResources }}
  resources:
    {{- toYaml $mainResources | nindent 4 }}
  {{- end }}
  {{- else }}
  {{- $resources := ($container.container).resources | default $container.resources -}}
  {{- with $resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if $mainContainer }}
  {{- include "common.volumeMounts" (dict "container" $container "root" $root) | nindent 2 }}
  {{- else }}
  {{- with $container.volumeMounts }}
  volumeMounts:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- with $container.volumeDevices }}
  volumeDevices:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.terminationMessagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with $container.terminationMessagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}
  {{- with $container.workingDir }}
  workingDir: {{ . }}
  {{- end }}
  {{- with $container.stdin }}
  stdin: {{ . }}
  {{- end }}
  {{- with $container.stdinOnce }}
  stdinOnce: {{ . }}
  {{- end }}
  {{- with $container.tty }}
  tty: {{ . }}
  {{- end }}
  securityContext:
    {{- include "common.containerSecurityContext" (dict "securityContext" $container.securityContext "root" $root) | nindent 4 }}
{{- end -}}

{{/*
Sidecar container template for native Kubernetes sidecar support
Uses init containers with restartPolicy: Always
*/}}
{{- define "common.sidecarContainer" -}}
{{- include "common.container" (dict "container" .container "root" .root "restartPolicy" "Always" "containerName" (.container.name | default "sidecar")) -}}
{{- end -}}
