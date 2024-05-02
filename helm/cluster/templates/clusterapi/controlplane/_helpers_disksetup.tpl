{{- define "cluster.internal.controlPlane.kubeadm.diskSetup" }}
filesystems:
{{- include "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" $ | indent 8 }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.diskSetup.filesystems" }}
{{- range $.Values.providerIntegration.controlPlane.kubeadmConfig.diskSetup.filesystems }}
  - device: {{ .device }}
    filesystem: {{ .filesystem }}
    label: {{ if .label }}{{ .label }}{{ end }}
    partition: {{ if .partition }}{{ .partition }}{{ end }}
    replaceFS: {{ if .replaceFS }}{{ .replaceFS }}{{ end }}
    overwrite: {{ .overwrite }}
    extraOpts: 
    {{- if .extraOpts }}
    {{- range .extraOpts }}
      - {{ . }}
    {{- end }}
    {{- end }}
{{- end }}
{{- end }}
