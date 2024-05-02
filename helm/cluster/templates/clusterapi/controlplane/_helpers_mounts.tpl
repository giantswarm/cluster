{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- if ($.Values.providerIntegration.controlPlane.kubeadmConfig).mounts }}
{{- include "cluster.internal.controlPlane.kubeadm.mounts" $.Values.providerIntegration.controlPlane.kubeadmConfig.mounts | indent 6 }}
{{- end }}
{{- end }}
