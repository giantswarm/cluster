{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.os" $ }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.teleport-init" $ }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.teleport" $ }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.kubernetes" $ }}
{{- end }}

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
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
    {{- if .contents.unit }}
    [Unit]
    Description={{ .contents.unit.description }}
    {{- if hasKey .contents.unit "defaultDependencies" }}
    DefaultDependencies={{ if .contents.unit.defaultDependencies }}yes{{ else }}no{{ end }}
    {{- end }}
    {{- if .contents.unit.after }}
    {{- range $after := .contents.unit.after }}
    After={{ $after }}
    {{- end }}
    {{- end }}
    {{- if .contents.unit.before }}
    {{- range $before := .contents.unit.before }}
    Before={{ $before }}
    {{- end }}
    {{- end }}
    {{- if .contents.unit.partOf }}
    {{- range $partOf := .contents.unit.partOf }}
    PartOf={{ $partOf }}
    {{- end }}
    {{- end }}
    {{- if .contents.unit.requires }}
    {{- range $requires := .contents.unit.requires }}
    Requires={{ $requires }}
    {{- end }}
    {{- end }}
    {{- if .contents.unit.upholds }}
    {{- range $upholds := .contents.unit.upholds }}
    Upholds={{ $upholds }}
    {{- end }}
    {{- end }}
    {{- if .contents.unit.wants }}
    {{- range $wants := .contents.unit.wants }}
    Wants={{ $wants }}
    {{- end }}
    {{- end }}
    {{- if .contents.unit.bindsTo }}
    BindsTo={{ .contents.unit.bindsTo }}
    {{- end }}
    {{- end }}
    {{- if .contents.service }}
    [Service]
    {{- if .contents.service.environment }}
    {{- range $environment := .contents.service.environment }}
    Environment={{ $environment }}
    {{- end }}
    {{- end }}
    {{- if .contents.service.environmentFile }}
    {{- range $environmentFile := .contents.service.environmentFile }}
    EnvironmentFile={{ $environmentFile }}
    {{- end }}
    {{- end }}
    Type={{ .contents.service.type }}
    RemainAfterExit={{ .contents.service.remainAfterExit }}
    {{- if .contents.service.restart }}
    Restart={{ .contents.service.restart }}
    {{- end }}
    {{- if .contents.service.execStart }}
    {{- range $execStart := .contents.service.execStart }}
    ExecStart={{ $execStart }}
    {{- end }}
    {{- end }}
    {{- if .contents.service.additionalFields }}
    {{- tpl .contents.service.additionalFields $ | nindent 4 }}
    {{- end }}
    {{- end }}
    {{- if .contents.mount }}
    [Mount]
    What={{ .contents.mount.what }}
    Where={{ .contents.mount.where }}
    {{- if .contents.mount.type }}
    Type={{ .contents.mount.type }}
    {{- end }}
    {{- end }}
    {{- if .contents.install }}
    [Install]
    {{- range $wantedBy := .contents.install.wantedBy }}
    WantedBy={{ $wantedBy }}
    {{- end }}
    {{- end }}
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
    {{- if hasKey .mount "wipeFilesystem" }}
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

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" }}
{{- range . }}
- device: {{ .device }}
  partitions:
  {{- range .partitions }}
  - number: {{ .number }}
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

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.os" }}
- name: os-hardening.service
  enabled: true
  contents: |
    [Unit]
    Description=Apply os hardening
    [Service]
    Type=oneshot
    ExecStartPre=-/bin/bash -c "gpasswd -d core rkt; gpasswd -d core docker; gpasswd -d core wheel"
    ExecStartPre=/bin/bash -c "until [ -f '/etc/sysctl.d/hardening.conf' ]; do echo Waiting for sysctl file; sleep 1s;done;"
    ExecStart=/usr/sbin/sysctl -p /etc/sysctl.d/hardening.conf
    [Install]
    WantedBy=multi-user.target
{{- /*
  Mask Flatcar's update-engine, locksmithd and sshkeys services, which are used for OS
  upgrades (update-engine is responsible for downloading and applying the
  updates, and locksmithd is the default reboot manager) and getting SSH keys from instance meta data service.
  We upgrade OS when we upgrade cluster chart version and for SSH we use teleport, so we don't want these
  services to be enabled.
*/}}
- name: update-engine.service
  enabled: false
  mask: true
- name: locksmithd.service
  enabled: false
  mask: true
- name: sshkeys.service
  enabled: false
  mask: true
{{- end }}

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.kubernetes" }}
- name: kubeadm.service
  dropins:
  - name: 10-flatcar.conf
    contents: |
      [Unit]
      # kubeadm must run after coreos-metadata populated /run/metadata directory.
      Requires=coreos-metadata.service
      After=coreos-metadata.service
      # kubeadm must run after containerd - see https://github.com/kubernetes-sigs/image-builder/issues/939.
      After=containerd.service
      # kubeadm requires having an IP
      After=network-online.target
      Wants=network-online.target
      [Service]
      # Ensure kubeadm service has access to kubeadm binary in /opt/bin on Flatcar.
      Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/bin
      # To make metadata environment variables available for pre-kubeadm commands.
      EnvironmentFile=/run/metadata/*
- name: containerd.service
  enabled: true
  contents: |
  dropins:
  - name: 10-change-cgroup.conf
    contents: |
      [Service]
      CPUAccounting=true
      MemoryAccounting=true
      Slice=kubereserved.slice
{{- if $.Values.global.components.auditd.enabled }}
- name: audit-rules.service
  enabled: true
  dropins:
  - name: 10-wait-for-containerd.conf
    contents: |
      [Service]
      ExecStartPre=/bin/bash -c "while [ ! -f /etc/audit/rules.d/containerd.rules ]; do echo 'Waiting for /etc/audit/rules.d/containerd.rules to be written' && sleep 1; done"
      Restart=on-failure
{{- else }}
- name: auditd.service
  enabled: false
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.teleport-init" }}
{{- if and $.Values.providerIntegration.teleport.enabled $.Values.providerIntegration.teleport.initialJoinToken }}
- name: teleport-init.service
  enabled: true
  contents: |
    [Unit]
    Description=Initialize Teleport Token
    Before=teleport.service
    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c 'echo {{ $.Values.providerIntegration.teleport.initialJoinToken | quote }} > /etc/teleport-join-token'
    RemainAfterExit=yes
    [Install]
    WantedBy=multi-user.target
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
    {{- if $.Values.providerIntegration.teleport.initialJoinToken }}
    After=network.target teleport-init.service
    Requires=teleport-init.service
    {{- end }}
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

{{/* Default directories on all nodes */}}
{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directorties.default" }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directorties.kubernetes" $ }}
{{- end }}

{{/* Kubernetes components directories on all nodes */}}
{{- define "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directorties.kubernetes" }}
- path: /var/lib/kubelet
  mode: 0750
{{- end }}
