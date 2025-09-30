{{- define "kube-auth.ns.argocd" -}}
{{ .Values.namespaces.argocd | default "argocd" }}
{{- end -}}

{{- define "kube-auth.ns.cm" -}}
{{ .Values.namespaces.certManager | default "cert-manager" }}
{{- end -}}

{{- define "kube-auth.ns.ing" -}}
{{ .Values.namespaces.ingress | default "ingress-nginx" }}
{{- end -}}

{{- define "kube-auth.ns.zit" -}}
{{ .Values.namespaces.zitadel | default "auth" }}
{{- end -}}

