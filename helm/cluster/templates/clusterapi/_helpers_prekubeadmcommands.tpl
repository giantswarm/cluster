{{/*
    Template cluster.internal.kubeadm.preKubeadmCommands defines common extra commands to run on all
    (control plane and workers) nodes before kubeadm runs. It includes prefedined commands and
    custom commands specified in Helm values field .Values.providerIntegration.kubeadmConfig.preKubeadmCommands.
*/}}
{{- define "cluster.internal.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.flatcar" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.ssh" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.proxy" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.flatcar" }}
- envsubst < /etc/kubeadm.yml > /etc/kubeadm.yml.tmp
- mv /etc/kubeadm.yml.tmp /etc/kubeadm.yml
- echo "---" >> /etc/kubeadm.yml
- cat /etc/kubelet-configuration.yaml >> /etc/kubeadm.yml
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.ssh" }}
{{- if $.Values.providerIntegration.resourcesApi.bastionResourceEnabled }}
{{- if .Values.global.connectivity.bastion.enabled }}
- systemctl restart sshd
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.proxy" }}
{{- if and $.Values.global.connectivity.proxy $.Values.global.connectivity.proxy.enabled }}
- export HTTP_PROXY={{ $.Values.global.connectivity.proxy.httpProxy }}
- export HTTPS_PROXY={{ $.Values.global.connectivity.proxy.httpsProxy }}
- export NO_PROXY="{{ include "cluster.internal.kubeadm.proxy.noProxyList" $ }}"
- export http_proxy={{ $.Values.global.connectivity.proxy.httpProxy }}
- export https_proxy={{ $.Values.global.connectivity.proxy.httpsProxy }}
- export no_proxy="{{ include "cluster.internal.kubeadm.proxy.noProxyList" $ }}"
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.custom" }}
{{- if $.Values.providerIntegration.kubeadmConfig }}
{{- range $command := $.Values.providerIntegration.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
