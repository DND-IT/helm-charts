{{/*
Full PodDisruptionBudget resource template.
Usage: {{- include "common.pdb" . }}
*/}}
{{/*
Render an int-or-percentage value: integers and all-digit strings stay integers, other strings (e.g. "50%") are quoted.
*/}}
{{- define "common.pdb.intOrPercent" -}}
{{- if and (kindIs "string" .) (not (regexMatch "^[0-9]+$" .)) -}}
{{- . | quote -}}
{{- else -}}
{{- . | int64 -}}
{{- end -}}
{{- end -}}

{{- define "common.pdb" -}}
{{- if and .Values.podDisruptionBudget .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ include "common.pdb.intOrPercent" .Values.podDisruptionBudget.minAvailable }}
  {{- end }}
  {{- if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ include "common.pdb.intOrPercent" .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end -}}
