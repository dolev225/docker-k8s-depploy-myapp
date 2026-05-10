{{/* Generate basic labels */}}
{{- define "myapp.labels" -}}
generator: helm
date: {{ now | htmlDate }}
name: {{ .Release.Name }}
{{- end -}}

{{/* Generate fullname */}}
{{- define "myapp.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}