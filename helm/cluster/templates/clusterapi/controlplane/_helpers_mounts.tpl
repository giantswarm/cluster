{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- include "cluster.internal.controlPlane.kubeadm.mounts" $ | indent 6 }}
{{- end }}


{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).mounts }}
{{- include "cluster.internal.controlPlane.kubeadm.mounts" $.Values.providerIntegration.kubeadmConfig.mounts }}
{{- end }}
