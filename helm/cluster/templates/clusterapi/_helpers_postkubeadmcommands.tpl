{{- define "cluster.internal.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands.kubelet" . }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands.custom" . }}
{{- end }}

{{- define "cluster.internal.kubeadm.postKubeadmCommands.kubelet" }}
- /bin/sh /opt/kubelet-config.sh
{{- end }}

{{- define "cluster.internal.kubeadm.postKubeadmCommands.custom" }}
{{- if $.Values.internal.kubeadmConfig }}
{{- range $command := $.Values.internal.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
{{- end }}
