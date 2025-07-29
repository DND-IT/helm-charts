{{/*
Container template for generic workloads
*/}}
{{- define "generic.container" -}}
{{- $container := .container -}}
{{- $root := .root -}}
- name: {{ $container.name | default "main" }}
  image: {{ include "generic.containerImage" (dict "container" $container "root" $root) }}
  imagePullPolicy: {{ $container.imagePullPolicy | default $root.Values.image.pullPolicy | default "IfNotPresent" }}
  {{- with $container.command }}
  command:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.args }}
  args:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if or $container.env $container.envFrom }}
  {{- with $container.env }}
  env:
    {{- include "generic.envVars" (dict "envVars" . "root" $root) | nindent 4 }}
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
  {{- with $container.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.volumeMounts }}
  volumeMounts:
    {{- toYaml . | nindent 4 }}
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
    {{- include "generic.containerSecurityContext" (dict "securityContext" $container.securityContext "root" $root) | nindent 4 }}
{{- end -}}

{{/*
Container image helper
*/}}
{{- define "generic.containerImage" -}}
{{- $container := .container -}}
{{- $root := .root -}}
{{- if $container.image -}}
  {{- if kindIs "string" $container.image -}}
    {{- $container.image -}}
  {{- else if and $container.image.repository $container.image.tag -}}
    {{- printf "%s:%s" $container.image.repository $container.image.tag -}}
  {{- else -}}
    {{- $container.image -}}
  {{- end -}}
{{- else -}}
  {{- include "generic.image" $root -}}
{{- end -}}
{{- end -}}

{{/*
Container security context with secure defaults
*/}}
{{- define "generic.containerSecurityContext" -}}
{{- $securityContext := .securityContext | default dict -}}
{{- $root := .root -}}
{{- $defaults := $root.Values.containerSecurityContext | default dict -}}
{{- if not (hasKey $securityContext "runAsNonRoot") }}
runAsNonRoot: {{ $defaults.runAsNonRoot | default true }}
{{- else if $securityContext.runAsNonRoot }}
runAsNonRoot: {{ $securityContext.runAsNonRoot }}
{{- end }}
{{- if not (hasKey $securityContext "runAsUser") }}
runAsUser: {{ $defaults.runAsUser | default 1000 }}
{{- else if $securityContext.runAsUser }}
runAsUser: {{ $securityContext.runAsUser }}
{{- end }}
{{- if not (hasKey $securityContext "allowPrivilegeEscalation") }}
allowPrivilegeEscalation: {{ $defaults.allowPrivilegeEscalation | default false }}
{{- else }}
allowPrivilegeEscalation: {{ $securityContext.allowPrivilegeEscalation }}
{{- end }}
{{- if not (hasKey $securityContext "readOnlyRootFilesystem") }}
readOnlyRootFilesystem: {{ $defaults.readOnlyRootFilesystem }}
{{- else }}
readOnlyRootFilesystem: {{ $securityContext.readOnlyRootFilesystem }}
{{- end }}
{{- if not (hasKey $securityContext "capabilities") }}
capabilities:
  drop:
  - ALL
  {{- with $defaults.capabilities }}
  {{- with .add }}
  add:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
{{- else }}
  {{- with $securityContext.capabilities }}
capabilities:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- with $securityContext.privileged }}
privileged: {{ . }}
{{- end }}
{{- with $securityContext.seLinuxOptions }}
seLinuxOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.windowsOptions }}
windowsOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $securityContext.runAsGroup }}
runAsGroup: {{ . }}
{{- end }}
{{- with $securityContext.procMount }}
procMount: {{ . }}
{{- end }}
{{- if $securityContext.seccompProfile }}
seccompProfile:
  {{- toYaml $securityContext.seccompProfile | nindent 2 }}
{{- else if $defaults.seccompProfile }}
seccompProfile:
  {{- toYaml $defaults.seccompProfile | nindent 2 }}
{{- else }}
seccompProfile:
  type: RuntimeDefault
{{- end }}
{{- if $securityContext.appArmorProfile }}
appArmorProfile:
  {{- toYaml $securityContext.appArmorProfile | nindent 2 }}
{{- else if $defaults.appArmorProfile }}
appArmorProfile:
  {{- toYaml $defaults.appArmorProfile | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Sidecar container template for native Kubernetes sidecar support
Uses init containers with restartPolicy: Always
*/}}
{{- define "generic.sidecarContainer" -}}
{{- $container := .container -}}
{{- $root := .root -}}
- name: {{ $container.name | default "sidecar" }}
  image: {{ include "generic.containerImage" (dict "container" $container "root" $root) }}
  imagePullPolicy: {{ $container.imagePullPolicy | default $root.Values.image.pullPolicy | default "IfNotPresent" }}
  restartPolicy: Always
  {{- with $container.command }}
  command:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.args }}
  args:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if or $container.env $container.envFrom }}
  {{- with $container.env }}
  env:
    {{- include "generic.envVars" (dict "envVars" . "root" $root) | nindent 4 }}
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
  {{- with $container.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.volumeMounts }}
  volumeMounts:
    {{- toYaml . | nindent 4 }}
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
    {{- include "generic.containerSecurityContext" (dict "securityContext" $container.securityContext "root" $root) | nindent 4 }}
{{- end -}}
