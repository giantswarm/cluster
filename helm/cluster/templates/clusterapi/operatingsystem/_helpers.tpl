{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
{{- with $.Values.internal.controlPlane.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd }}
{{- range .units }}
- name: {{ .name }}
  {{- if hasKey . "enabled" }}
  enabled: {{ .enabled }}
  {{- end }}
  {{- if hasKey . "mask" }}
  mask: {{ .mask }}
  {{- end }}
  {{- if .contents }}
  contents: |
    {{- .contents | trim | nindent 4 }}
  {{- end }}
  {{- if .dropins }}
  dropins:
  {{- range .dropins }}
  - name: {{ .name }}
    {{- if .contents }}
    contents: |
      {{- .contents | trim | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
