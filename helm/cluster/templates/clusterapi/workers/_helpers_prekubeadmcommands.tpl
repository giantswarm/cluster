{{/*
    Template cluster.internal.workers.kubeadm.preKubeadmCommands defines extra commands to run
    on worker nodes before kubeadm runs. It includes prefedined commands and custom commands
    specified in Helm values field .Values.providerIntegration.workers.kubeadmConfig.preKubeadmCommands.
*/}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands" $ }}
{{- include "cluster.internal.workers.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands.custom" }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig }}
{{- range $command := $.Values.providerIntegration.workers.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
