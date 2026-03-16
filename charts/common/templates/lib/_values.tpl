{{/*
Merge the common library chart defaults with the consuming chart's values.
The library's values appear under .Values.common (the dependency name).
The consuming chart's values override the library defaults via deep merge.
Usage: {{- include "common.values.init" . -}}
*/}}
{{- define "common.values.init" -}}
  {{- if .Values.common -}}
    {{- $defaultValues := deepCopy .Values.common -}}
    {{- $userValues := deepCopy (omit .Values "common") -}}
    {{- $mergedValues := mustMergeOverwrite $defaultValues $userValues -}}
    {{- $_ := set . "Values" (deepCopy $mergedValues) -}}
  {{- end -}}
{{- end -}}
