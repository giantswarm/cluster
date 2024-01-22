{{- define "cluster.internal.controlPlane.kubeadm.ignition" }}
containerLinuxConfig:
  additionalConfig: |
    systemd:
      units:
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" $ | indent 6 }}
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" $ | indent 6 }}
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $ | indent 6 }}
    storage:
      filesystems:
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $ | indent 6 }}
      directories:
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directorties.default" $ | indent 6 }}
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $ | indent 6 }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- end }}
{{- if (((((($.Values.providerIntegration.controlPlane).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $.Values.providerIntegration.controlPlane.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- end }}
{{- end }}

{{/* Default systemd units on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" }}
- name: setup-apiserver-environment.service
  enabled: true
  contents: |
    [Unit]
    Description=Setup environment for kubeadm apiserver
    Before=kubeadm.service
    [Service]
    Type=oneshot
    TimeoutStartSec=0
    ExecStart=/opt/bin/setup-apiserver-environment.sh
    [Install]
    WantedBy=multi-user.target
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).filesystems }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- if (((((($.Values.providerIntegration.controlPlane).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).filesystems }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $.Values.providerIntegration.controlPlane.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).directories }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.directories }}
{{- end }}
{{- if (((((($.Values.providerIntegration.controlPlane).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).directories }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $.Values.providerIntegration.controlPlane.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.directories }}
{{- end }}
{{- end }}
