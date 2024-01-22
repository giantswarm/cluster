{{- define "cluster.internal.controlPlane.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.kubeadm.files.kubernetes" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.custom" $ }}
{{- if $.Values.global.controlPlane.oidc.caPem }}
- path: /etc/ssl/certs/oidc.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssl/certs/oidc.pem") . | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.kubernetes" }}
- path: /etc/kubernetes/policies/audit-policy.yaml
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/kubernetes/policies/audit-policy.yaml" | b64enc }}
- path: /etc/kubernetes/encryption/config.yaml
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-encryption-provider-config
      key: encryption
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.controlPlane.files }}
{{ toYaml $.Values.internal.advancedConfiguration.controlPlane.files }}
{{- end }}
{{- end }}
