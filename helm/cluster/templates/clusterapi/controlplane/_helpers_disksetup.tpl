{{- define "cluster.internal.controlPlane.kubeadm.diskSetup" }}
filesystems:
{{- include "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" $ }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" }}
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
  {{- if .overwrite }}
  overwrite: {{ .overwrite }}
  {{- end }}
  {{- if .partition }}
  partition: {{ .partition }}
  {{- end }}
  {{- if .replaceFS }}
  replaceFS: {{ .replaceFS }}
  {{- end }}
{{- end }}
{{- end }}
