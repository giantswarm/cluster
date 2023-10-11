{{/*
    Template cluster.internal.controlPlane.kubeadm.postKubeadmCommands defines extra commands to run
    on worker nodes after kubeadm runs. It includes prefedined commands and custom commands
    specified in Helm values field .Values.internal.workers.kubeadmConfig.postKubeadmCommands.
*/}}
{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands" . }}
{{- include "cluster.internal.workers.kubeadm.postKubeadmCommands.custom" . }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands.custom" }}
{{- if $.Values.internal.workers.kubeadmConfig }}
{{- range $command := $.Values.internal.workers.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
