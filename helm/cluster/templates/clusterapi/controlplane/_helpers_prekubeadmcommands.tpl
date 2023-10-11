{{/*
    Template cluster.internal.controlPlane.kubeadm.preKubeadmCommands defines extra commands to run
    on control plane nodes before kubeadm runs. It includes prefedined commands and custom commands
    specified in Helm values field .Values.internal.controlPlane.kubeadmConfig.preKubeadmCommands.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.custom" }}
{{- if $.Values.internal.controlPlane.kubeadmConfig }}
{{- range $command := $.Values.internal.controlPlane.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
