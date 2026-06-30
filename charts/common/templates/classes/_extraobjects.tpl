{{/*
Extra Objects resource template for arbitrary Kubernetes resources.

Accepts either form:

  # List form (order preserved):
  extraObjects:
    - apiVersion: v1
      kind: ConfigMap
      ...

  # Map form (keyed by name, overlay/merge friendly):
  extraObjects:
    my-config:
      apiVersion: v1
      kind: ConfigMap
      ...

The map form lets additional values files (overlays) deep-merge and override
individual fields of an existing entry instead of replacing the whole list.
Each map entry may set `enabled: false` to drop it (the key is omitted from the
rendered manifest). Both forms support a plain string value, which is rendered
through the template engine.

Usage: {{- include "common.extraObjects" . }}
*/}}
{{- define "common.extraObjects" -}}
{{- $root := . -}}
{{- $objects := .Values.extraObjects -}}
{{- if kindIs "map" $objects -}}
{{- range $name, $object := $objects }}
{{- $enabled := true -}}
{{- $manifest := $object -}}
{{- if and (kindIs "map" $object) (hasKey $object "enabled") -}}
{{- $enabled = $object.enabled -}}
{{- $manifest = omit $object "enabled" -}}
{{- end -}}
{{- if $enabled }}
---
{{- if kindIs "string" $manifest }}
{{- include "common.tplValue" (dict "value" $manifest "context" $root) | nindent 0 }}
{{- else }}
{{- toYaml $manifest | nindent 0 }}
{{- end }}
{{- end }}
{{- end }}
{{- else -}}
{{- range $objects }}
---
{{- if typeIs "string" . }}
{{- include "common.tplValue" (dict "value" . "context" $root) | nindent 0 }}
{{- else }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}
