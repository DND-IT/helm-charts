{{/*
Volumes template for generic workloads
*/}}
{{- define "generic.volumes" -}}
{{- $root := . -}}
{{- $volumes := list -}}

{{/* ConfigMap volumes */}}
{{- if .Values.configMap.enabled -}}
  {{- if .Values.configMap.mountPath -}}
    {{- $volume := dict "name" "config" "configMap" (dict "name" (include "generic.configMapName" .)) -}}
    {{- $volumes = append $volumes $volume -}}
  {{- end -}}
{{- end -}}

{{/* Secret volumes */}}
{{- if .Values.secret.enabled -}}
  {{- if .Values.secret.mountPath -}}
    {{- $volume := dict "name" "secret" "secret" (dict "secretName" (include "generic.secretName" .) "defaultMode" 420) -}}
    {{- $volumes = append $volumes $volume -}}
  {{- end -}}
{{- end -}}

{{/* Extra ConfigMap volumes */}}
{{- range $name, $config := .Values.extraConfigMaps -}}
  {{- if $config.mountPath -}}
    {{- $volume := dict "name" (printf "configmap-%s" $name) "configMap" (dict "name" $name) -}}
    {{- if $config.items -}}
      {{- $_ := set $volume.configMap "items" $config.items -}}
    {{- end -}}
    {{- if $config.defaultMode -}}
      {{- $_ := set $volume.configMap "defaultMode" $config.defaultMode -}}
    {{- end -}}
    {{- $volumes = append $volumes $volume -}}
  {{- end -}}
{{- end -}}

{{/* Extra Secret volumes */}}
{{- range $name, $config := .Values.extraSecrets -}}
  {{- if $config.mountPath -}}
    {{- $volume := dict "name" (printf "secret-%s" $name) "secret" (dict "secretName" $name "defaultMode" 420) -}}
    {{- if $config.items -}}
      {{- $_ := set $volume.secret "items" $config.items -}}
    {{- end -}}
    {{- if $config.defaultMode -}}
      {{- $_ := set $volume.secret "defaultMode" $config.defaultMode -}}
    {{- end -}}
    {{- $volumes = append $volumes $volume -}}
  {{- end -}}
{{- end -}}

{{/* Persistent volumes */}}
{{- if .Values.persistence.enabled -}}
  {{- range $name, $pvc := .Values.persistence.volumes -}}
    {{- if $pvc.enabled | default true -}}
      {{- $volume := dict "name" $name "persistentVolumeClaim" (dict "claimName" (printf "%s-%s" (include "generic.fullname" $root) $name)) -}}
      {{- $volumes = append $volumes $volume -}}
    {{- end -}}
  {{- end -}}
{{- else if .Values.persistence.enabled -}}
  {{- $volume := dict "name" "data" "persistentVolumeClaim" (dict "claimName" (include "generic.pvcName" .)) -}}
  {{- $volumes = append $volumes $volume -}}
{{- end -}}

{{/* EmptyDir volumes */}}
{{- range $name, $config := .Values.emptyDirVolumes -}}
  {{- $volume := dict "name" $name "emptyDir" dict -}}
  {{- if $config.medium -}}
    {{- $_ := set $volume.emptyDir "medium" $config.medium -}}
  {{- end -}}
  {{- if $config.sizeLimit -}}
    {{- $_ := set $volume.emptyDir "sizeLimit" $config.sizeLimit -}}
  {{- end -}}
  {{- $volumes = append $volumes $volume -}}
{{- end -}}

{{/* HostPath volumes */}}
{{- range $name, $config := .Values.hostPathVolumes -}}
  {{- $volume := dict "name" $name "hostPath" (dict "path" $config.path) -}}
  {{- if $config.type -}}
    {{- $_ := set $volume.hostPath "type" $config.type -}}
  {{- end -}}
  {{- $volumes = append $volumes $volume -}}
{{- end -}}

{{/* Extra volumes */}}
{{- with .Values.extraVolumes -}}
  {{- $volumes = concat $volumes . -}}
{{- end -}}

{{/* Output volumes */}}
{{- if $volumes -}}
volumes:
  {{- toYaml $volumes | nindent 0 }}
{{- end -}}
{{- end -}}

{{/*
Volume mounts template
*/}}
{{- define "generic.volumeMounts" -}}
{{- $container := .container -}}
{{- $root := .root -}}
{{- $mounts := list -}}

{{/* ConfigMap mounts */}}
{{- if $root.Values.configMap.enabled -}}
  {{- if $root.Values.configMap.mountPath -}}
    {{- $mount := dict "name" "config" "mountPath" $root.Values.configMap.mountPath -}}
    {{- if $root.Values.configMap.subPath -}}
      {{- $_ := set $mount "subPath" $root.Values.configMap.subPath -}}
    {{- end -}}
    {{- $mounts = append $mounts $mount -}}
  {{- end -}}
{{- end -}}

{{/* Secret mounts */}}
{{- if $root.Values.secret.enabled -}}
  {{- if $root.Values.secret.mountPath -}}
    {{- $mount := dict "name" "secret" "mountPath" $root.Values.secret.mountPath -}}
    {{- if $root.Values.secret.subPath -}}
      {{- $_ := set $mount "subPath" $root.Values.secret.subPath -}}
    {{- end -}}
    {{- $mounts = append $mounts $mount -}}
  {{- end -}}
{{- end -}}

{{/* Extra ConfigMap mounts */}}
{{- range $name, $config := $root.Values.extraConfigMaps -}}
  {{- if $config.mountPath -}}
    {{- $mount := dict "name" (printf "configmap-%s" $name) "mountPath" $config.mountPath -}}
    {{- if $config.subPath -}}
      {{- $_ := set $mount "subPath" $config.subPath -}}
    {{- end -}}
    {{- if $config.readOnly -}}
      {{- $_ := set $mount "readOnly" $config.readOnly -}}
    {{- end -}}
    {{- $mounts = append $mounts $mount -}}
  {{- end -}}
{{- end -}}

{{/* Extra Secret mounts */}}
{{- range $name, $config := $root.Values.extraSecrets -}}
  {{- if $config.mountPath -}}
    {{- $mount := dict "name" (printf "secret-%s" $name) "mountPath" $config.mountPath -}}
    {{- if $config.subPath -}}
      {{- $_ := set $mount "subPath" $config.subPath -}}
    {{- end -}}
    {{- if $config.readOnly -}}
      {{- $_ := set $mount "readOnly" $config.readOnly -}}
    {{- end -}}
    {{- $mounts = append $mounts $mount -}}
  {{- end -}}
{{- end -}}

{{/* Persistent volume mounts */}}
{{- if $root.Values.persistence.enabled -}}
  {{- range $name, $pvc := $root.Values.persistence.volumes -}}
    {{- if $pvc.enabled | default true -}}
      {{- $mount := dict "name" $name "mountPath" $pvc.mountPath -}}
      {{- if $pvc.subPath -}}
        {{- $_ := set $mount "subPath" $pvc.subPath -}}
      {{- end -}}
      {{- if $pvc.readOnly -}}
        {{- $_ := set $mount "readOnly" $pvc.readOnly -}}
      {{- end -}}
      {{- $mounts = append $mounts $mount -}}
    {{- end -}}
  {{- end -}}
{{- else if $root.Values.persistence.enabled -}}
  {{- $mount := dict "name" "data" "mountPath" ($root.Values.persistence.mountPath | default "/data") -}}
  {{- if $root.Values.persistence.subPath -}}
    {{- $_ := set $mount "subPath" $root.Values.persistence.subPath -}}
  {{- end -}}
  {{- $mounts = append $mounts $mount -}}
{{- end -}}

{{/* EmptyDir mounts */}}
{{- range $name, $config := $root.Values.emptyDirVolumes -}}
  {{- $mount := dict "name" $name "mountPath" $config.mountPath -}}
  {{- if $config.subPath -}}
    {{- $_ := set $mount "subPath" $config.subPath -}}
  {{- end -}}
  {{- if $config.readOnly -}}
    {{- $_ := set $mount "readOnly" $config.readOnly -}}
  {{- end -}}
  {{- $mounts = append $mounts $mount -}}
{{- end -}}

{{/* HostPath mounts */}}
{{- range $name, $config := $root.Values.hostPathVolumes -}}
  {{- $mount := dict "name" $name "mountPath" $config.mountPath -}}
  {{- if $config.subPath -}}
    {{- $_ := set $mount "subPath" $config.subPath -}}
  {{- end -}}
  {{- if $config.readOnly -}}
    {{- $_ := set $mount "readOnly" $config.readOnly -}}
  {{- end -}}
  {{- $mounts = append $mounts $mount -}}
{{- end -}}

{{/* Container-specific volume mounts */}}
{{- with $container.volumeMounts -}}
  {{- $mounts = concat $mounts . -}}
{{- end -}}

{{/* Extra volume mounts */}}
{{- with $root.Values.extraVolumeMounts -}}
  {{- $mounts = concat $mounts . -}}
{{- end -}}

{{/* Output mounts */}}
{{- if $mounts -}}
volumeMounts:
  {{- toYaml $mounts | nindent 0 }}
{{- end -}}
{{- end -}}
