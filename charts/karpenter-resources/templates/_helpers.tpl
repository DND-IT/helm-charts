{{/*
Expand the name of the chart.
*/}}
{{- define "karpenter-resources.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "karpenter-resources.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "karpenter-resources.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "karpenter-resources.labels" -}}
helm.sh/chart: {{ include "karpenter-resources.chart" . }}
{{ include "karpenter-resources.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "karpenter-resources.selectorLabels" -}}
app.kubernetes.io/name: {{ include "karpenter-resources.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Resolve a NodePool field that may be written either as a list or as a
name-keyed map, applying `nodePools.defaults` underneath the per-pool value,
and render the result as a YAML sequence.

Arguments (dict):
  defaults - map holding the default value for `key` (may be nil)
  override - map holding the per-pool value for `key` (may be nil)
  key      - field name: "requirements", "taints", "startupTaints", "budgets"

Both arguments accept either form:

  # List form: order preserved, replaced wholesale by any overlay.
  requirements:
    - key: karpenter.k8s.aws/instance-cpu
      operator: In
      values: ["4", "8"]

  # Map form: keyed by a short alias. Helm deep-merges maps, so an overlay can
  # change a single field of a single entry without restating the others.
  requirements:
    instance-cpu:
      key: karpenter.k8s.aws/instance-cpu
      operator: In
      values: ["4", "8"]

Resolution:
  * both map form  -> per-pool map is deep-merged over the defaults map, so
                      sibling default entries survive;
  * per-pool list  -> replaces the defaults entirely (pre-1.1.0 behaviour);
  * per-pool unset -> the defaults value is used as-is;
  * a map entry with `enabled: false` is dropped, and `enabled` is never
    rendered into the manifest.

Map entries are emitted in sorted key order, so output is deterministic.
Returns "" when there is nothing to render, so callers guard the parent key
with `if`.

Usage:
  {{- $reqs := include "karpenter-resources.nodePoolEntries" (dict "defaults" $defaults "override" $pool "key" "requirements") }}
  {{- if $reqs }}
  requirements:
    {{- $reqs | nindent 8 }}
  {{- end }}
*/}}
{{- define "karpenter-resources.nodePoolEntries" -}}
{{- $key := .key -}}
{{- $defaults := default (dict) .defaults -}}
{{- $override := default (dict) .override -}}
{{- $value := index $defaults $key -}}
{{- if hasKey $override $key -}}
{{- $poolValue := index $override $key -}}
{{- if and (kindIs "map" $value) (kindIs "map" $poolValue) -}}
{{- $value = mustMergeOverwrite (deepCopy $value) $poolValue -}}
{{- else -}}
{{- $value = $poolValue -}}
{{- end -}}
{{- end -}}
{{- $items := list -}}
{{- if kindIs "map" $value -}}
{{- range $alias, $entry := $value -}}
{{- if kindIs "map" $entry -}}
{{- if or (not (hasKey $entry "enabled")) $entry.enabled -}}
{{- $items = append $items (omit $entry "enabled") -}}
{{- end -}}
{{- else if $entry -}}
{{- $items = append $items $entry -}}
{{- end -}}
{{- end -}}
{{- else if kindIs "slice" $value -}}
{{- $items = $value -}}
{{- end -}}
{{- if $items -}}
{{- toYaml $items -}}
{{- end -}}
{{- end -}}
