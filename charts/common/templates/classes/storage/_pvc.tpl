{{/*
PersistentVolumeClaim resource template.
Usage: {{- include "common.pvc" . }}
*/}}
{{- define "common.pvc" -}}
{{- range $name, $pvc := .Values.volumes.persistent }}
{{- if ne (toString $pvc.enabled) "false" }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ printf "%s-%s" (include "common.fullname" $) $name }}
  namespace: {{ include "common.namespace" $ }}
  labels:
    {{- include "common.labels" (dict "context" $ "labels" $pvc.labels) | nindent 4 }}
  {{- if or $pvc.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $pvc.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- if $pvc.accessModes }}
  accessModes:
    {{- toYaml $pvc.accessModes | nindent 4 }}
  {{- else if $pvc.accessMode }}
  accessModes:
    - {{ $pvc.accessMode }}
  {{- else }}
  accessModes:
    - ReadWriteOnce
  {{- end }}
  {{- with $pvc.volumeMode }}
  volumeMode: {{ . }}
  {{- end }}
  resources:
    requests:
      storage: {{ $pvc.size | default "8Gi" }}
  {{- if $pvc.storageClass }}
  {{- if eq "-" $pvc.storageClass }}
  storageClassName: ""
  {{- else }}
  storageClassName: {{ $pvc.storageClass }}
  {{- end }}
  {{- end }}
  {{- with $pvc.selector }}
  selector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $pvc.volumeName }}
  volumeName: {{ . }}
  {{- end }}
  {{- with $pvc.dataSource }}
  dataSource:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $pvc.dataSourceRef }}
  dataSourceRef:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}
