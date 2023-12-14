{{/*
    Template cluster.internal.bastion.kubeadm.preKubeadmCommands defines extra commands to run
    on bastion nodes before kubeadm runs. It includes prefedined commands and custom commands
    specified in Helm values field .Values.providerIntegration.bastion.kubeadmConfig.preKubeadmCommands.
*/}}
{{- define "cluster.internal.bastion.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.flatcar" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.ssh" $ }}
{{- include "cluster.internal.bastion.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{- define "cluster.internal.bastion.kubeadm.preKubeadmCommands.custom" }}
{{- if $.Values.providerIntegration.bastion.kubeadmConfig }}
{{- range $command := $.Values.providerIntegration.bastion.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
