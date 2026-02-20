{{/*
Container template for workloads
*/}}
{{- define "common.container" -}}
{{- $container := .container -}}
{{- $root := .root -}}
- name: {{ $container.name | default "main" }}
  image: {{ include "common.containerImage" (dict "container" $container "root" $root) }}
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
    {{- include "common.containerSecurityContext" (dict "securityContext" $container.securityContext "root" $root) | nindent 4 }}
{{- end -}}

{{/*
Sidecar container template for native Kubernetes sidecar support
Uses init containers with restartPolicy: Always
*/}}
{{- define "common.sidecarContainer" -}}
{{- $container := .container -}}
{{- $root := .root -}}
- name: {{ $container.name | default "sidecar" }}
  image: {{ include "common.containerImage" (dict "container" $container "root" $root) }}
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
    {{- include "common.containerSecurityContext" (dict "securityContext" $container.securityContext "root" $root) | nindent 4 }}
{{- end -}}
