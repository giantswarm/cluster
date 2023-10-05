{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands" . }}
{{- end }}
