{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- range $.Values.providerIntegration.controlPlane.kubeadmConfig.mounts }}
- {{- range . }}
  - {{ . }}
{{- end }}
{{- end }}
{{- end }}
