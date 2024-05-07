{{- define "cluster.internal.controlPlane.kubeadm.mounts" }}
{{- range $.Values.providerIntegration.controlPlane.kubeadmConfig.mounts }}
  - - {{ index . 0 }}
    - {{ index . 1 }}
{{- end }}
{{- end }}
