{{/*
Single hook job template helper.
Usage: {{- include "common.hookJob" (dict "hooks" $hooks "hookType" "pre-install" "defaultDeletePolicy" "before-hook-creation" "root" $) }}
*/}}
{{- define "common.hookJob" -}}
{{- range $hook := .hooks }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s-%s" (include "common.fullname" $.root) $.hookType $hook.name }}
  namespace: {{ include "common.namespace" $.root }}
  labels:
    {{- $extraLabels := merge (dict "app.kubernetes.io/component" "hook" "app.kubernetes.io/hook-type" $.hookType) ($hook.labels | default dict) }}
    {{- include "common.labels" (dict "context" $.root "labels" $extraLabels) | nindent 4 }}
  annotations:
    {{- $helmAnnotations := dict "helm.sh/hook" $.hookType "helm.sh/hook-weight" ($hook.weight | default 1 | toString) "helm.sh/hook-delete-policy" ($hook.deletePolicy | default $.defaultDeletePolicy) }}
    {{- $allAnnotations := merge $helmAnnotations ($hook.annotations | default dict) }}
    {{- include "common.annotations" (dict "context" $.root "annotations" $allAnnotations) | nindent 4 }}
spec:
  {{- with $hook.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ . }}
  {{- end }}
  {{- with $hook.backoffLimit }}
  backoffLimit: {{ . }}
  {{- end }}
  template:
    metadata:
      labels:
        {{- include "common.selectorLabels" $.root | nindent 8 }}
        app.kubernetes.io/component: hook
        app.kubernetes.io/hook-type: {{ $.hookType }}
      annotations:
        {{- include "common.podAnnotations" $.root | nindent 8 }}
    spec:
      restartPolicy: {{ $hook.restartPolicy | default "Never" }}
      {{- with $hook.imagePullSecrets | default $.root.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if $.root.Values.serviceAccount.enabled }}
      serviceAccountName: {{ include "common.serviceAccountName" $.root }}
      {{- else if $.root.Values.serviceAccount.name }}
      serviceAccountName: {{ $.root.Values.serviceAccount.name }}
      {{- end }}
      securityContext:
        {{- include "common.podSecurityContext" (dict "securityContext" $.root.Values.security.defaultPodSecurityContext "defaults" $.root.Values.security.defaultPodSecurityContext) | nindent 8 }}
      containers:
      - name: {{ $hook.name }}
        image: {{ include "common.resolveStringImage" (dict "image" $hook.image "root" $.root) }}
        imagePullPolicy: {{ $hook.imagePullPolicy | default $.root.Values.image.pullPolicy | default "IfNotPresent" }}
        {{- with $hook.command }}
        command:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $hook.args }}
        args:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $hook.env }}
        env:
          {{- include "common.envVars" (dict "envVars" . "root" $.root) | nindent 10 }}
        {{- end }}
        {{- with $hook.envFrom }}
        envFrom:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $hook.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $hook.volumeMounts }}
        volumeMounts:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        securityContext:
          {{- include "common.containerSecurityContext" (dict "securityContext" $hook.securityContext "root" $.root) | nindent 10 }}
      {{- with $hook.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}

{{/*
Full Helm hooks resource template.
Usage: {{- include "common.hooks" . }}
*/}}
{{- define "common.hooks" -}}
{{- if and .Values.hooks .Values.hooks.enabled }}
{{- with .Values.hooks.preInstall }}
{{- include "common.hookJob" (dict "hooks" . "hookType" "pre-install" "defaultDeletePolicy" "before-hook-creation" "root" $) }}
{{- end }}
{{- with .Values.hooks.postInstall }}
{{- include "common.hookJob" (dict "hooks" . "hookType" "post-install" "defaultDeletePolicy" "hook-succeeded" "root" $) }}
{{- end }}
{{- with .Values.hooks.preUpgrade }}
{{- include "common.hookJob" (dict "hooks" . "hookType" "pre-upgrade" "defaultDeletePolicy" "before-hook-creation" "root" $) }}
{{- end }}
{{- with .Values.hooks.postUpgrade }}
{{- include "common.hookJob" (dict "hooks" . "hookType" "post-upgrade" "defaultDeletePolicy" "hook-succeeded" "root" $) }}
{{- end }}
{{- with .Values.hooks.preDelete }}
{{- include "common.hookJob" (dict "hooks" . "hookType" "pre-delete" "defaultDeletePolicy" "hook-succeeded" "root" $) }}
{{- end }}
{{- with .Values.hooks.postDelete }}
{{- include "common.hookJob" (dict "hooks" . "hookType" "post-delete" "defaultDeletePolicy" "hook-succeeded" "root" $) }}
{{- end }}
{{- end }}
{{- end -}}
