{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands" . }}
{{- end }}
