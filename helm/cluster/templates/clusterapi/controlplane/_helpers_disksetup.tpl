{{- define "cluster.internal.controlPlane.kubeadm.diskSetup" }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.diskSetup.filesystems }}
filesystems:
{{- range $.Values.providerIntegration.controlPlane.kubeadmConfig.diskSetup.filesystems }}
- device: {{ .device }}
  {{- if .extraOpts }}
  extraOpts: 
  {{- range .extraOpts }}
  - {{ . }}
  {{- end }}
  {{- end }}
  filesystem: {{ .filesystem }}
  {{- if .label }}
  label: {{ .label }}
  {{- end }}
  overwrite: {{ .overwrite }}
  {{- if .partition }}
  partition: {{ .partition }}
  {{- end }}
  {{- if .replaceFS }}
  replaceFS: {{ .replaceFS }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
