{{- define "cluster.internal.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files.sysctl" . }}
{{- include "cluster.internal.kubeadm.files.systemd" . }}
{{- include "cluster.internal.kubeadm.files.ssh" . }}
{{- include "cluster.internal.kubeadm.files.kubelet" . }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.sysctl" }}
- path: /etc/sysctl.d/hardening.conf
  permissions: "0644"
  encoding: base64
  content: {{ $.Files.Get "files/etc/sysctl.d/hardening.conf" | b64enc }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.systemd" }}
{{- if and $.Values.internal.kubeadmConfig $.Values.internal.kubeadmConfig.systemd }}
{{- if and $.Values.internal.kubeadmConfig $.Values.internal.kubeadmConfig.systemd.timesyncd }}
- path: /etc/systemd/timesyncd.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/timesyncd.conf") . | b64enc }}
{{- end }}
{{- end }}
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

{{- define "cluster.internal.kubeadm.files.ssh" }}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config" | b64enc }}
{{- end }}
