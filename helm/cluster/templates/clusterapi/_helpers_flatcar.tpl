{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.teleport" $ }}
{{- end }}

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
{{- range . }}
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

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" }}
{{- range . }}
- name: {{ .name }}
  {{- if .mount }}
  mount:
    device: {{ .mount.device }}
    format: {{ .mount.format }}
    {{- if hasKey . "wipeFilesystem" }}
    wipeFilesystem: {{ .mount.wipeFilesystem }}
    {{- end }}
    {{- if .mount.label }}
    label: {{ .mount.label }}
    {{- end }}
    {{- if .mount.uuid }}
    uuid: {{ .mount.uuid }}
    {{- end }}
    {{- if .mount.options }}
    {{- range $option := .mount.options }}
    - {{ $option }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- if .path }}
  path: {{ .path }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" }}
{{- range . }}
- path: {{ .path }}
  {{- if hasKey . "overwrite" }}
  overwrite: {{ .overwrite }}
  {{- end }}
  {{- if .filesystem }}
  filesystem: {{ .filesystem }}
  {{- end }}
  {{- if .mode }}
  mode: {{ .mode }}
  {{- end }}
  {{- if .user }}
  user:
    {{- if .user.id }}
    id: {{ .user.id }}
    {{- end }}
    {{- if .user.name }}
    name: {{ .user.name }}
    {{- end }}
  {{- end }}
  {{- if .group }}
  group:
    {{- if .group.id }}
    id: {{ .group.id }}
    {{- end }}
    {{- if .group.name }}
    name: {{ .group.name }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.teleport" }}
{{- if $.Values.providerIntegration.teleport.enabled }}
- name: teleport.service
  enabled: true
  contents: |
    [Unit]
    Description=Teleport Service
    After=network.target

    [Service]
    Type=simple
    Restart=on-failure
    ExecStart=/opt/bin/teleport start --roles=node --config=/etc/teleport.yaml --pid-file=/run/teleport.pid
    ExecReload=/bin/kill -HUP $MAINPID
    PIDFile=/run/teleport.pid
    LimitNOFILE=524288

    [Install]
    WantedBy=multi-user.target
{{- end }}
{{- end }}
