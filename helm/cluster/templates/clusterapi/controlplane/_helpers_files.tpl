{{- define "cluster.internal.controlPlane.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" . -}}
{{- if .Values.controlPlane.oidc.caPem }}
- path: /etc/ssl/certs/oidc.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssl/certs/oidc.pem") . | b64enc }}
{{- end }}
{{- end }}
