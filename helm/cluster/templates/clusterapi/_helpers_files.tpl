{{- define "cluster.internal.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files.sysctl" $ }}
{{- include "cluster.internal.kubeadm.files.cri" $ }}
{{- include "cluster.internal.kubeadm.files.selinux" $ }}
{{- include "cluster.internal.kubeadm.files.systemd" $ }}
{{- include "cluster.internal.kubeadm.files.ssh" $ }}
{{- include "cluster.internal.kubeadm.files.kubelet" $ }}
{{- include "cluster.internal.kubeadm.files.proxy" $ }}
{{- include "cluster.internal.kubeadm.files.teleport" $ }}
{{- include "cluster.internal.kubeadm.files.auditrules" $ }}
{{- include "cluster.internal.kubeadm.files.provider" $ }}
{{- include "cluster.internal.kubeadm.files.ntpd" $ }}
{{- include "cluster.internal.kubeadm.files.custom" $ }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.sysctl" }}
- path: /etc/sysctl.d/hardening.conf
  permissions: "0644"
  encoding: base64
  content: {{ $.Files.Get "files/etc/sysctl.d/hardening.conf" | b64enc }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.selinux" }}
- path: /etc/selinux/config
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/selinux/config") . | b64enc }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.systemd" }}
{{- if ($.Values.providerIntegration.components.systemd).timesyncd }}
- path: /etc/systemd/timesyncd.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/timesyncd.conf") . | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.ssh" }}
{{- if or (and .Values.providerIntegration.resourcesApi.bastionResourceEnabled .Values.global.connectivity.bastion.enabled) .Values.providerIntegration.kubeadmConfig.enableGiantswarmUser }}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config" | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.kubelet" }}
- path: /etc/kubernetes/patches/kubeletconfiguration.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/kubernetes/patches/kubeletconfiguration.yaml") . | b64enc }}
- path: /etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf
  permissions: "0700"
  encoding: base64
  content: {{ $.Files.Get "files/etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf" | b64enc }}
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
- path: /opt/bin/teleport-auto-update.sh
  permissions: "0755"
  encoding: base64
  content: {{ $.Files.Get "files/opt/bin/teleport-auto-update.sh" | b64enc }}
- path: /etc/teleport.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/teleport.yaml") . | b64enc }}
{{- if and $.Values.providerIntegration.teleport.autoUpdate.enabled $.Values.providerIntegration.teleport.autoUpdate.manualVersionOverride }}
- path: /etc/teleport-target-version
  permissions: "0644"
  encoding: base64
  content: {{ $.Values.providerIntegration.teleport.autoUpdate.manualVersionOverride | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{/* Audit rules for all nodes */}}
{{- define "cluster.internal.kubeadm.files.auditrules" }}
{{- if $.Values.global.components.auditd.enabled }}
- path: /etc/audit/rules.d/99-default.rules
  permissions: "0640"
  encoding: base64
  content: {{ $.Files.Get "files/etc/audit/rules.d/99-default.rules" | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.ntpd" }}
{{- if ($.Values.providerIntegration.components.systemd).ntpd }}
{{- if $.Values.providerIntegration.components.systemd.ntpd.enabled }}
- path: /etc/ntp.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ntp.conf") . | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{/* Provider-specific files for all nodes */}}
{{- define "cluster.internal.kubeadm.files.provider" }}
{{- if $.Values.providerIntegration.kubeadmConfig.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.providerIntegration.kubeadmConfig.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific files for all nodes */}}
{{- define "cluster.internal.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.internal.advancedConfiguration.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.cri" }}
- path: /etc/containerd/config.toml
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-containerd-{{ include "cluster.data.hash" (dict "data" (tpl ($.Files.Get "files/etc/containerd/config.toml") $) "salt" $.Values.providerIntegration.hashSalt) }}
      key: config.toml
{{- end }}

{{- define "cluster.internal.processFiles" }}
{{- $clusterName := required "clusterName is required for cluster.internal.processFiles function call" .clusterName }}
{{- $outFiles := list }}
{{- range $file := .files }}
{{- if default false (index $file "contentFrom" "secret" "prependClusterNameAsPrefix") }}
{{- $secret := (index $file "contentFrom" "secret") }}
{{- $secretName := (required "Secret name must be given" (index $secret "name")) }}
{{- $_ := set $secret "name" (printf "%s-%s" $clusterName $secretName) }}
{{- /* `prependClusterNameAsPrefix` is our own property, so remove it to make the dictionary CAPI-compatible */}}
{{- $_ := unset $secret "prependClusterNameAsPrefix" }}
{{- end }}
{{- $outFiles = append $outFiles $file }}
{{- end }}
{{- toYaml $outFiles }}
{{- end }}
