{{/*
Fails the render when a value that every monitor depends on is missing.
*/}}
{{- define "app-monitors.validate" -}}
{{- $_ := required "app-monitors: .Values.team is required (routing tag)" .Values.team -}}
{{- $_ = required "app-monitors: .Values.app is required" .Values.app -}}
{{- $_ = required "app-monitors: .Values.env is required" .Values.env -}}
{{- end -}}

{{- define "app-monitors.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ .Values.app }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "app-monitors.tags" -}}
- "team:{{ .Values.team }}"
- "env:{{ .Values.env }}"
- "service:{{ .Values.app }}"
- "managed-by:app-monitors"
{{- range .Values.extraTags }}
- {{ . | quote }}
{{- end }}
{{- end -}}

{{- define "app-monitors.kubeScope" -}}
kube_namespace:{{ required "app-monitors: .Values.scope.kubeNamespace is required by the workload and HPA monitors" .Values.scope.kubeNamespace }}
{{- end -}}

{{- define "app-monitors.kubePrefix" -}}
{{`{{aws_account_alias.name}}`}} - {{`{{kube_cluster_name.name}}`}}
{{- end -}}

{{- define "app-monitors.sqsScope" -}}
{{- if not .Values.scope.sqsQueues -}}
{{- fail "app-monitors: .Values.scope.sqsQueues is required by the SQS monitors" -}}
{{- end -}}
env:{{ .Values.env }} AND ({{ range $i, $q := .Values.scope.sqsQueues }}{{ if $i }} OR {{ end }}queuename:{{ $q }}{{ end }})
{{- end -}}

{{/*
Renders one DatadogMonitor. Every monitor template calls this, so the CR shape,
name, tags and options are defined once.

Takes a dict:
  root      the chart root context ($)
  monitor   the monitor's values block (.Values.monitors.<name>)
  signal    kebab-case suffix of the resource name, e.g. pod-restarts
  prefix    text inside the brackets that start the monitor title
  title     monitor title after "[<prefix>] <app> - "
  query     full Datadog query
  critical  critical threshold, the same number the query compares against
  message   alert text; no @-handles, routing is done on tags
*/}}
{{- define "app-monitors.monitor" -}}
{{- $v := .root.Values -}}
{{- include "app-monitors.validate" .root -}}
---
apiVersion: datadoghq.com/v1alpha1
kind: DatadogMonitor
metadata:
  name: {{ printf "%s-%s-%s" $v.app $v.env .signal }}
  labels:
    {{- include "app-monitors.labels" .root | nindent 4 }}
spec:
  name: {{ printf "[%s] %s - %s" .prefix $v.app .title | quote }}
  type: query alert
  query: {{ .query | quote }}
  message: {{ .message | quote }}
  priority: {{ .monitor.priority }}
  tags:
    {{- include "app-monitors.tags" .root | nindent 4 }}
  options:
    thresholds:
      critical: {{ .critical | toString | quote }}
      {{- if hasKey .monitor "warning" }}
      warning: {{ .monitor.warning | toString | quote }}
      {{- end }}
    notifyNoData: false
    renotifyInterval: {{ $v.renotifyInterval }}
    includeTags: true
{{- end -}}
