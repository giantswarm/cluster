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
{{- $_ := include "cluster.internal.get-internal-values" $ }}
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
- path: /etc/teleport.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/teleport.yaml") . | b64enc }}
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

{{- define "cluster.containerd.hosts.toml" -}}
{{- $registry := .registry -}}
{{- $mirrors := .mirrors -}}
server = "https://{{ $registry }}"

{{- /* Local Registry Cache */ -}}
{{- if and .Values.global.components.containerd.localRegistryCache.enabled (has $registry .Values.global.components.containerd.localRegistryCache.mirroredRegistries) }}
[host."http://127.0.0.1:{{ .Values.global.components.containerd.localRegistryCache.port }}"]
  capabilities = ["pull", "resolve"]
  override_path = false
{{- end }}

{{- /* Management Cluster Registry Cache */ -}}
{{- if and .Values.global.components.containerd.managementClusterRegistryCache.enabled (has $registry .Values.global.components.containerd.managementClusterRegistryCache.mirroredRegistries) }}
[host."https://zot.{{ .Values.global.managementCluster }}.{{ .Values.global.connectivity.baseDomain }}"]
  capabilities = ["pull", "resolve"]
  override_path = false
{{- end }}

{{- /* Configured Mirrors */ -}}
{{- range $mirror := $mirrors }}
{{- if $mirror.insecure }}
[host."http://{{ $mirror.endpoint }}"]
{{- else }}
[host."https://{{ $mirror.endpoint }}"]
{{- end }}
  capabilities = ["pull", "resolve"]
  {{- if ne $mirror.endpoint $registry }}
  override_path = false
  {{- else if $mirror.enableOverridePath }}
  override_path = true
  {{- end }}
  {{- if $mirror.skipVerify }}
  skip_verify = true
  {{- else }}
  skip_verify = false
  {{- end }}
  {{- with $mirror.credentials }}
    {{- if or (and .username .password) .auth .identitytoken }}
  [host."https://{{ $mirror.endpoint }}".header]
      {{- if and .username .password }}
    Authorization = ["Basic {{ printf "%s:%s" .username .password | b64enc }}"]
      {{- else if .auth }}
    Authorization = ["Basic {{ .auth }}"]
      {{- else if .identitytoken }}
    Authorization = ["Bearer {{ .identitytoken }}"]
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "cluster.internal.kubeadm.files.cri" }}
- path: /etc/containerd/config.toml
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-containerd-{{ include "cluster.data.hash" (dict "data" (tpl ($.Files.Get "files/etc/containerd/config.toml") $) "salt" $.Values.providerIntegration.hashSalt) }}
      key: config.toml

{{- $containerMirrors := include "cluster.container.mirrors" $ | fromYaml }}
{{- range $host, $config := $containerMirrors }}
- path: /etc/containerd/certs.d/{{ $host }}/hosts.toml
  permissions: "0644"
  encoding: base64
  content: {{ include "cluster.containerd.hosts.toml" (dict "registry" $host "mirrors" $config "Values" $.Values) | b64enc }}
{{- end }}
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
