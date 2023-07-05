{{- define "cluster.os.config" -}}
{{- if eq .Values.internal.operatingSystem "flatcar" -}}
ignition:
  containerLinuxConfig:
    additionalConfig: |
      systemd:
        units:
        {{- include "cluster.os.flatcar.systemdUnits" $ | nindent 8 }}
{{- end }}
{{- end }}

{{- define "cluster.os.kubeadmConfigSpecFormat" -}}
{{- if eq .Values.internal.operatingSystem "flatcar" -}}
ignition
{{- else if eq .Values.internal.operatingSystem "ubuntu" -}}
cloud-config
{{- else -}}
{{- fail "Invalid operating system" }}
{{- end -}}
{{- end -}}

{{- define "cluster.os.flatcar.systemdUnits" -}}
- name: kubereserved.slice
  path: /etc/systemd/system/kubereserved.slice
  content: |
    [Unit]
    Description=Limited resources slice for Kubernetes services
    Documentation=man:systemd.special(7)
    DefaultDependencies=no
    Before=slices.target
    Requires=-.slice
    After=-.slice
- name: kubeadm.service
  dropins:
  - name: 10-flatcar.conf
    contents: |
      [Unit]
      # kubeadm must run after coreos-metadata populated /run/metadata directory.
      Requires=coreos-metadata.service
      After=coreos-metadata.service
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
- name: audit-rules.service
  enabled: true
  dropins:
  - name: 10-wait-for-containerd.conf
    contents: |
      [Service]
      ExecStartPre=/bin/bash -c "while [ ! -f /etc/audit/rules.d/containerd.rules ]; do echo 'Waiting for /etc/audit/rules.d/containerd.rules to be written' && sleep 1; done"
- name: update-engine.service
  enabled: false
  mask: true
- name: locksmithd.service
  enabled: false
  mask: true
{{- end -}}
