{{- define "cluster.internal.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files.sysctl" $ }}
{{- include "cluster.internal.kubeadm.files.systemd" $ }}
{{- include "cluster.internal.kubeadm.files.ssh" $ }}
{{- include "cluster.internal.kubeadm.files.cri" $ }}
{{- include "cluster.internal.kubeadm.files.kubelet" $ }}
{{- include "cluster.internal.kubeadm.files.proxy" $ }}
{{- include "cluster.internal.kubeadm.files.teleport" $ }}
{{- include "cluster.internal.kubeadm.files.custom" $ }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.sysctl" }}
- path: /etc/sysctl.d/hardening.conf
  permissions: "0644"
  encoding: base64
  content: {{ $.Files.Get "files/etc/sysctl.d/hardening.conf" | b64enc }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.systemd" }}
{{- if and $.Values.providerIntegration.kubeadmConfig $.Values.providerIntegration.kubeadmConfig.systemd }}
{{- if and $.Values.providerIntegration.kubeadmConfig $.Values.providerIntegration.kubeadmConfig.systemd.timesyncd }}
- path: /etc/systemd/timesyncd.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/timesyncd.conf") . | b64enc }}
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

{{- define "cluster.internal.kubeadm.files.cri" }}
- path: /etc/containerd/config.toml
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-registry-configuration {{/* TODO: rename *-registry-configuration to -containerd-configuration */}}
      key: registry-config.toml {{/* TODO: rename *-registry-config.toml to -containerd-config.toml */}}
{{- end }}

{{- define "cluster.internal.kubeadm.files.kubelet" }}
{{- if and $.Values.providerIntegration.kubeadmConfig $.Values.providerIntegration.kubeadmConfig.kubelet }}
- path: /opt/kubelet-config.sh
  permissions: "0700"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/opt/kubelet-config.sh") . | b64enc }}
{{- if $.Values.providerIntegration.kubeadmConfig.kubelet.gracefulNodeShutdown }}
- path: /etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf
  permissions: "0700"
  encoding: base64
  content: {{ $.Files.Get "files/etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf" | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.proxy" }}
{{- if and $.Values.global.connectivity.proxy $.Values.global.connectivity.proxy.enabled }}
- path: /etc/systemd/system/containerd.service.d/http-proxy.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/http-proxy.conf") $ | b64enc }}
- path: /etc/systemd/system/kubelet.service.d/http-proxy.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/http-proxy.conf") $ | b64enc }}
{{- if $.Values.providerIntegration.teleport.enabled }}
- path: /etc/systemd/system/teleport.service.d/http-proxy.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/http-proxy.conf") $ | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{/*
The secret `-teleport-join-token` is created by the teleport-operator in cluster namespace
and is used to join the node to the teleport cluster.
*/}}
{{- define "cluster.internal.kubeadm.files.teleport" }}
{{- if $.Values.providerIntegration.teleport.enabled }}
- path: /etc/teleport-join-token
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-teleport-join-token
      key: joinToken
- path: /opt/teleport-node-role.sh
  permissions: "0755"
  encoding: base64
  content: {{ $.Files.Get "files/opt/teleport-node-role.sh" | b64enc }}
- path: /etc/teleport.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/teleport.yaml") . | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.custom" }}
{{- if $.Values.providerIntegration.kubeadmConfig.files }}
{{ toYaml $.Values.providerIntegration.kubeadmConfig.files }}
{{- end }}
{{- end }}
