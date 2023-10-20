{{/*
    Template cluster.internal.controlPlane.kubeadm.postKubeadmCommands defines extra commands to run
    on control plane nodes after kubeadm runs. It includes prefedined commands and custom commands
    specified in Helm values field .Values.internal.controlPlane.kubeadmConfig.postKubeadmCommands.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.custom" $ }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.custom" }}
{{- if $.Values.internal.controlPlane.kubeadmConfig }}
{{- range $command := $.Values.internal.controlPlane.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
