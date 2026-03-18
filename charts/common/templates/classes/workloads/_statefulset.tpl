{{/*
Full StatefulSet resource template.
Usage: {{- include "common.statefulset" . }}
*/}}
{{- define "common.statefulset" -}}
{{- if and (eq (.Values.workload.type | default "") "statefulset") .Values.image.repository }}
apiVersion: apps/v1
kind: StatefulSet
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
  {{- if not .Values.hpa.enabled }}
  replicas: {{ .Values.replicas | default 1 }}
  {{- end }}
  {{- with .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  serviceName: {{ .Values.statefulset.serviceName | default (include "common.fullname" .) }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: main
  {{- with .Values.statefulset.podManagementPolicy }}
  podManagementPolicy: {{ . }}
  {{- end }}
  {{- with .Values.statefulset.updateStrategy }}
  updateStrategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.statefulset.ordinals }}
  ordinals:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.statefulset.persistentVolumeClaimRetentionPolicy }}
  persistentVolumeClaimRetentionPolicy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    {{- include "common.podTemplate" . | nindent 4 }}
  {{- if .Values.statefulset.volumeClaimTemplates }}
  volumeClaimTemplates:
    {{- range $name, $vct := .Values.statefulset.volumeClaimTemplates }}
    - metadata:
        name: {{ $name }}
        {{- with $vct.labels }}
        labels:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $vct.annotations }}
        annotations:
          {{- toYaml . | nindent 10 }}
        {{- end }}
      spec:
        {{- if $vct.accessModes }}
        accessModes:
          {{- toYaml $vct.accessModes | nindent 10 }}
        {{- else }}
        accessModes:
          - ReadWriteOnce
        {{- end }}
        {{- with $vct.volumeMode }}
        volumeMode: {{ . }}
        {{- end }}
        resources:
          requests:
            storage: {{ $vct.size | default "8Gi" }}
        {{- if $vct.storageClass }}
        {{- if eq $vct.storageClass "-" }}
        storageClassName: ""
        {{- else }}
        storageClassName: {{ $vct.storageClass }}
        {{- end }}
        {{- end }}
        {{- with $vct.selector }}
        selector:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with $vct.dataSource }}
        dataSource:
          {{- toYaml . | nindent 10 }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
