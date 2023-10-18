{{- define "cluster.internal.bastion.kubeadm.files" }}
{{- include "cluster.internal.bastion.kubeadm.files.ssh" $ }}
{{- end }}

{{- define "cluster.internal.bastion.kubeadm.files.ssh" }}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config_bastion" | b64enc }}
{{- end }}
