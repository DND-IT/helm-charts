{{/*
StorageClass resource template.
Renders one cluster-scoped StorageClass per entry in .Values.volumes.storageClasses.
Each StorageClass is named "<release-fullname>-<key>" so parallel releases of the
same chart (e.g. PR previews) never collide on the cluster-scoped name. A
persistent volume whose `storageClass` matches a key here is auto-wired to this
name by common.pvc.
Usage: {{- include "common.storageClass" . }}
*/}}
{{- define "common.storageClass" -}}
{{- range $name, $sc := .Values.volumes.storageClasses }}
{{- if ne (toString $sc.enabled) "false" }}
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ printf "%s-%s" (include "common.fullname" $) $name }}
  labels:
    {{- include "common.labels" (dict "context" $ "labels" $sc.labels) | nindent 4 }}
  {{- if or $sc.annotations $.Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" $ "annotations" $sc.annotations) | nindent 4 }}
  {{- end }}
provisioner: {{ required (printf "volumes.storageClasses.%s.provisioner is required" $name) $sc.provisioner }}
{{- with $sc.parameters }}
parameters:
  {{- range $k, $v := . }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
{{- end }}
{{- with $sc.reclaimPolicy }}
reclaimPolicy: {{ . }}
{{- end }}
{{- with $sc.volumeBindingMode }}
volumeBindingMode: {{ . }}
{{- end }}
{{- if hasKey $sc "allowVolumeExpansion" }}
allowVolumeExpansion: {{ $sc.allowVolumeExpansion }}
{{- end }}
{{- with $sc.mountOptions }}
mountOptions:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $sc.allowedTopologies }}
allowedTopologies:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
