{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- range $.Values.providerIntegration.controlPlane.kubeadmConfig.mounts }}
- - {{ (split " " .)._0 }}
  - {{ (split " " .)._1 }}
{{- end }}
{{- end }}
