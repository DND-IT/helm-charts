{{/*
Create image name with optional registry override
Usage: include "common.image" (dict "image" .Values.image "context" .)
Supports:
  image.registry: "my-registry.com" - Prepends custom registry
  image.repository: "nginx" or "docker.io/library/nginx"
  image.tag: "1.25"
If explicit registry is set, it will replace any existing registry in repository.
Falls back to global.image.registry when no per-image registry is specified.
If repository already contains a registry and no explicit registry is set, leave it unchanged.
*/}}
{{- define "common.image" -}}
  {{- $image := .image -}}
  {{- $context := .context | default dict -}}
  {{- if and $image $image.repository -}}
    {{- $explicitRegistry := $image.registry | default "" -}}
    {{- $globalRegistry := ((($context.Values).global).image).registry | default "" -}}
    {{- $repository := $image.repository -}}
    {{- $tag := $image.tag | default "" -}}
    {{- $repoHasRegistry := false -}}
    {{- if contains "/" $repository -}}
      {{- $firstPart := index (splitList "/" $repository) 0 -}}
      {{- if or (contains "." $firstPart) (contains ":" $firstPart) -}}
        {{- $repoHasRegistry = true -}}
      {{- end -}}
    {{- end -}}
    {{- if $explicitRegistry -}}
      {{/* Explicit registry set - strip any existing registry from repository and use explicit */}}
      {{- if $repoHasRegistry -}}
        {{- $firstPart := index (splitList "/" $repository) 0 -}}
        {{- $repository = trimPrefix (printf "%s/" $firstPart) $repository -}}
      {{- end -}}
      {{- if $tag -}}
        {{- printf "%s/%s:%s" $explicitRegistry $repository $tag -}}
      {{- else -}}
        {{- printf "%s/%s" $explicitRegistry $repository -}}
      {{- end -}}
    {{- else if $repoHasRegistry -}}
      {{/* Repository already has a registry and no explicit override - use as-is */}}
      {{- if $tag -}}
        {{- printf "%s:%s" $repository $tag -}}
      {{- else -}}
        {{- $repository -}}
      {{- end -}}
    {{- else if $globalRegistry -}}
      {{/* No explicit registry, no registry in repo, but global registry exists */}}
      {{- if $tag -}}
        {{- printf "%s/%s:%s" $globalRegistry $repository $tag -}}
      {{- else -}}
        {{- printf "%s/%s" $globalRegistry $repository -}}
      {{- end -}}
    {{- else -}}
      {{/* No registry anywhere */}}
      {{- if $tag -}}
        {{- printf "%s:%s" $repository $tag -}}
      {{- else -}}
        {{- $repository -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Resolve a plain string image with global registry support
Usage: include "common.resolveStringImage" (dict "image" "nginx:1.25" "root" $)
- If the image string contains {{ }}, it is passed through unchanged (template control)
- If the first path segment already contains "." or ":", it already has a registry - leave unchanged
- Otherwise, prepends the effective registry (image.registry → global.image.registry fallback)
*/}}
{{- define "common.resolveStringImage" -}}
  {{- $image := .image -}}
  {{- $root := .root -}}
  {{- if contains "{{" $image -}}
    {{- tpl $image $root -}}
  {{- else -}}
    {{- $registry := $root.Values.image.registry | default (($root.Values.global).image).registry | default "" -}}
    {{- if and $registry (ne $registry "") -}}
      {{- $hasRegistry := false -}}
      {{- if contains "/" $image -}}
        {{- $firstPart := index (splitList "/" $image) 0 -}}
        {{- if or (contains "." $firstPart) (contains ":" $firstPart) -}}
          {{- $hasRegistry = true -}}
        {{- end -}}
      {{- end -}}
      {{- if $hasRegistry -}}
        {{- $image -}}
      {{- else -}}
        {{- printf "%s/%s" $registry $image -}}
      {{- end -}}
    {{- else -}}
      {{- $image -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Container image helper
Supports same registry override functionality as common.image
If container.image.registry is not set, inherits from root image.registry
Supports template strings with {{ }} syntax via tpl function
*/}}
{{- define "common.containerImage" -}}
{{- $container := .container -}}
{{- $root := .root -}}
{{- if $container.image -}}
  {{- if kindIs "string" $container.image -}}
    {{- include "common.resolveStringImage" (dict "image" $container.image "root" $root) -}}
  {{- else if $container.image.repository -}}
    {{- $imageConfig := dict -}}
    {{- range $key, $value := $container.image -}}
      {{- if and (kindIs "string" $value) (contains "{{" $value) -}}
        {{- $_ := set $imageConfig $key (tpl $value $root) -}}
      {{- else -}}
        {{- $_ := set $imageConfig $key $value -}}
      {{- end -}}
    {{- end -}}
    {{/* Only set explicit registry if container has one - let common.image handle global fallback */}}
    {{- if not $imageConfig.registry -}}
      {{- $effectiveRegistry := $root.Values.image.registry | default "" -}}
      {{- if $effectiveRegistry -}}
        {{- $imageConfig = merge (dict "registry" $effectiveRegistry) $imageConfig -}}
      {{- end -}}
    {{- end -}}
    {{- include "common.image" (dict "image" $imageConfig "context" $root) -}}
  {{- else -}}
    {{- $container.image -}}
  {{- end -}}
{{- else -}}
  {{- include "common.image" (dict "image" $root.Values.image "context" $root) -}}
{{- end -}}
{{- end -}}
