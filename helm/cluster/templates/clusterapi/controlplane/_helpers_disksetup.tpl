{{- define "cluster.internal.controlPlane.kubeadm.diskSetup" }}
filesystems:
  {{- include "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" $ | indent 8 }}
{{- end }}


{{- define "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" }}
{{- if (($.Values.providerIntegration.kubeadmConfig).diskSetup).filesystems }}
{{- include "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" $.Values.providerIntegration.kubeadmConfig.diskSetup.filesystems}}
{{- end }}
{{- end }}
