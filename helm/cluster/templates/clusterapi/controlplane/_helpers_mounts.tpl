{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- range $.Values.providerIntegration.controlPlane.kubeadmConfig.mounts }}
  - {{ . }}
{{- end }}
{{- end }}
