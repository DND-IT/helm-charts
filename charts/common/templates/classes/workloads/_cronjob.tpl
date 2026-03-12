{{/*
Full CronJob resource template.
Usage: {{- include "common.cronjob" . }}
*/}}
{{- define "common.cronjob" -}}
{{- if .Values.schedule }}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.workloadLabels) | nindent 4 }}
  {{- if or .Values.workloadAnnotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.workloadAnnotations) | nindent 4 }}
  {{- end }}
spec:
  schedule: {{ .Values.schedule | quote }}
  concurrencyPolicy: {{ .Values.concurrencyPolicy | default "Forbid" }}
  successfulJobsHistoryLimit: {{ .Values.successfulJobsHistoryLimit | default 3 }}
  failedJobsHistoryLimit: {{ .Values.failedJobsHistoryLimit | default 1 }}
  {{- with .Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  suspend: {{ .Values.suspend | default false }}
  jobTemplate:
    metadata:
      labels:
        {{- include "common.labels" . | nindent 8 }}
    spec:
      {{- with .Values.job.backoffLimit }}
      backoffLimit: {{ . }}
      {{- end }}
      {{- with .Values.job.ttlSecondsAfterFinished }}
      ttlSecondsAfterFinished: {{ . }}
      {{- end }}
      {{- with .Values.job.completions }}
      completions: {{ . }}
      {{- end }}
      {{- with .Values.job.parallelism }}
      parallelism: {{ . }}
      {{- end }}
      {{- with .Values.job.activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ . }}
      {{- end }}
      {{- with .Values.job.completionMode }}
      completionMode: {{ . }}
      {{- end }}
      template:
        metadata:
          labels:
            {{- include "common.labels" . | nindent 12 }}
            {{- with .Values.pod.labels }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- with .Values.pod.annotations }}
          annotations:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        spec:
          {{- with .Values.imagePullSecrets }}
          imagePullSecrets:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if .Values.serviceAccount.enabled }}
          serviceAccountName: {{ include "common.serviceAccountName" . }}
          {{- else if .Values.serviceAccount.name }}
          serviceAccountName: {{ .Values.serviceAccount.name }}
          {{- end }}
          restartPolicy: {{ .Values.pod.restartPolicy | default "OnFailure" }}
          {{- with .Values.pod.hostAliases }}
          hostAliases:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if .Values.pod.hostNetwork }}
          hostNetwork: true
          {{- end }}
          {{- if .Values.pod.hostPID }}
          hostPID: true
          {{- end }}
          {{- if .Values.pod.hostIPC }}
          hostIPC: true
          {{- end }}
          {{- with .Values.pod.hostname }}
          hostname: {{ . }}
          {{- end }}
          {{- with .Values.pod.dnsPolicy }}
          dnsPolicy: {{ . }}
          {{- end }}
          {{- with .Values.pod.dnsConfig }}
          dnsConfig:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.pod.priorityClassName }}
          priorityClassName: {{ . }}
          {{- end }}
          {{- with .Values.pod.priority }}
          priority: {{ . }}
          {{- end }}
          {{- with .Values.pod.runtimeClassName }}
          runtimeClassName: {{ . }}
          {{- end }}
          {{- with .Values.pod.schedulerName }}
          schedulerName: {{ . }}
          {{- end }}
          {{- with .Values.pod.terminationGracePeriodSeconds }}
          terminationGracePeriodSeconds: {{ . }}
          {{- end }}
          {{- with .Values.scheduling.nodeSelector }}
          nodeSelector:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.scheduling.affinity }}
          affinity:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.scheduling.tolerations }}
          tolerations:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          securityContext:
            {{- include "common.podSecurityContext" (dict "securityContext" .Values.pod.securityContext "defaults" .Values.security.defaultPodSecurityContext) | nindent 12 }}
          {{- if and .Values.resources (not (empty .Values.resources)) }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          {{- end }}
          {{- with .Values.initContainers }}
          initContainers:
            {{- range $container := . }}
            {{- include "common.container" (dict "container" $container "root" $) | nindent 12 }}
            {{- end }}
          {{- end }}
          containers:
            - name: main
              image: {{ include "common.image" (dict "image" .Values.image "context" .) }}
              imagePullPolicy: {{ .Values.image.pullPolicy }}
              {{- with .Values.command }}
              command:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- with .Values.args }}
              args:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- if or .Values.env .Values.commonEnvVars }}
              {{- if .Values.commonEnvVars }}
              env:
                {{- include "common.commonEnvVars" . | nindent 16 }}
                {{- with .Values.env }}
                {{- include "common.envVars" (dict "envVars" . "root" $) | nindent 16 }}
                {{- end }}
              {{- else if .Values.env }}
              env:
                {{- include "common.envVars" (dict "envVars" .Values.env "root" .) | nindent 16 }}
              {{- end }}
              {{- end }}
              {{- include "common.envFrom" . | nindent 14 }}
              {{- with .Values.container.resources }}
              resources:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- include "common.volumeMounts" (dict "container" .Values "root" .) | nindent 14 }}
              {{- with .Values.lifecycle }}
              lifecycle:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              securityContext:
                {{- include "common.containerSecurityContext" (dict "securityContext" .Values.securityContext "root" .) | nindent 16 }}
          {{- include "common.volumes" . | nindent 10 }}
{{- end }}
{{- end -}}
