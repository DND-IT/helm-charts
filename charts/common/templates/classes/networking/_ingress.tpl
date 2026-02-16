{{/*
Full Ingress resource template.
Usage: {{- include "common.ingress" . }}
*/}}
{{- define "common.ingress" -}}
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ include "common.namespace" . }}
  labels:
    {{- include "common.labels" (dict "context" . "labels" .Values.ingress.labels) | nindent 4 }}
  {{- if or .Values.ingress.annotations .Values.commonAnnotations }}
  annotations:
    {{- include "common.annotations" (dict "context" . "annotations" .Values.ingress.annotations) | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- with .Values.ingress.defaultBackend }}
  defaultBackend:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.ingress.hosts }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ include "common.tplValue" (dict "value" .host "context" $) | quote }}
      http:
        paths:
          {{- if .paths }}
          {{- range .paths }}
          - path: {{ .path | default "/" }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                {{- if .backend }}
                {{- if .backend.service }}
                name: {{ .backend.service.name | default (include "common.fullname" $) }}
                port:
                  {{- if .backend.service.port.name }}
                  name: {{ .backend.service.port.name }}
                  {{- else }}
                  number: {{ .backend.service.port.number | default 80 }}
                  {{- end }}
                {{- else }}
                name: {{ include "common.fullname" $ }}
                port:
                  name: http
                {{- end }}
                {{- else }}
                name: {{ include "common.fullname" $ }}
                port:
                  {{- if .port }}
                  number: {{ .port }}
                  {{- else }}
                  name: http
                  {{- end }}
                {{- end }}
          {{- end }}
          {{- else }}
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ include "common.fullname" $ }}
                port:
                  name: http
          {{- end }}
    {{- end }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ include "common.tplValue" (dict "value" . "context" $) | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
