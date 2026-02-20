{{/*
Render value with template support
*/}}
{{- define "common.tplValue" -}}
{{- if typeIs "string" .value }}
{{- tpl .value .context }}
{{- else }}
{{- tpl (.value | toYaml) .context }}
{{- end }}
{{- end }}

{{/*
Render YAML dict/map with template support for string values
Recursively evaluates template strings in dictionary values
*/}}
{{- define "common.tplYaml" -}}
{{- $context := .context -}}
{{- $value := .value -}}
{{- range $key, $val := $value }}
{{- if kindIs "string" $val }}
{{- if contains "{{" $val }}
{{ $key }}: {{ tpl $val $context | toYaml }}
{{- else }}
{{ $key }}: {{ $val | toYaml }}
{{- end }}
{{- else }}
{{ $key }}: {{ $val | toYaml }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Get the preferred API version for a resource
Usage: {{ include "common.apiVersion" (dict "kind" "ExternalSecret" "group" "external-secrets.io" "versions" (list "v1" "v1beta1") "context" .) }}
*/}}
{{- define "common.apiVersion" -}}
{{- $group := .group -}}
{{- $kind := .kind -}}
{{- $preferredVersion := "" -}}
{{- range .versions -}}
  {{- if $.context.Capabilities.APIVersions.Has (printf "%s/%s/%s" $group . $kind) -}}
    {{- $preferredVersion = printf "%s/%s" $group . -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- $preferredVersion -}}
{{- end }}
