{{- define "cluster.internal.kubeadm.files" }}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config" | b64enc }}
{{- include "cluster.internal.kubeadm.files.kubelet" . -}}
{{- end }}

{{- define "cluster.internal.kubeadm.files.kubelet" }}
{{- if and $.Values.internal.kubeadmConfig $.Values.internal.kubeadmConfig.kubelet }}
- path: /opt/kubelet-config.sh
  permissions: "0700"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/opt/kubelet-config.sh") . | b64enc }}
{{- if $.Values.internal.kubeadmConfig.kubelet.gracefulNodeShutdown }}
- path: /etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf
  permissions: "0700"
  encoding: base64
  content: {{ $.Files.Get "files/etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf" | b64enc }}
{{- end }}
{{- end }}
{{- end }}
