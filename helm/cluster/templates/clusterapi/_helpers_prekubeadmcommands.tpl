{{/*
    Template cluster.internal.kubeadm.preKubeadmCommands defines common commands to run on all
    (control plane and workers) nodes before kubeadm runs.

    It includes:
    - provider-independent commands defined in cluster chart,
    - provider-specific commands specified in cluster-<provider> app,
    - custom cluster-specific commands.
*/}}
{{- define "cluster.internal.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.flatcar" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.ssh" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.proxy" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.provider" $ }}
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
- export NO_PROXY="{{ include "cluster.connectivity.proxy.noProxy" (dict "global" $.Values.global "providerIntegration" $.Values.providerIntegration) }}"
- export http_proxy={{ $.Values.global.connectivity.proxy.httpProxy }}
- export https_proxy={{ $.Values.global.connectivity.proxy.httpsProxy }}
- export no_proxy="{{ include "cluster.connectivity.proxy.noProxy" (dict "global" $.Values.global "providerIntegration" $.Values.providerIntegration) }}"
{{- end }}
{{- end }}

{{/* Provider-specific commands to run before kubeadm on all nodes */}}
{{- define "cluster.internal.kubeadm.preKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run before kubeadm on all nodes */}}
{{- define "cluster.internal.kubeadm.preKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
