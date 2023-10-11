{{/*
    Template cluster.internal.kubeadm.preKubeadmCommands defines common extra commands to run on all
    (control plane and workers) nodes before kubeadm runs. It includes prefedined commands and
    custom commands specified in Helm values field .Values.internal.kubeadmConfig.preKubeadmCommands.
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
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.ssh" }}
- systemctl restart sshd
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
{{- if $.Values.internal.kubeadmConfig }}
{{- range $command := $.Values.internal.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
