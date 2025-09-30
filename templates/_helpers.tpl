{{/*
Return kube-auth namespace
*/}}
{{- define "kube-auth.ns" -}}
{{ .Values.namespaces.kubeAuth | default "auth" }}
{{- end }}

