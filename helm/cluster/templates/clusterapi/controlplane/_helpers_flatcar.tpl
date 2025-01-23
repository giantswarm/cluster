{{- define "cluster.internal.controlPlane.kubeadm.ignition" }}
containerLinuxConfig:
  additionalConfig: |
    systemd:
      units:
      {{- $_ := set $ "nodeRole" "controlplane" }}
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" $ | indent 6 }}
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" $ | indent 6 }}
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $ | indent 6 }}
    storage:
      filesystems:
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $ | indent 6 }}
      directories:
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directorties.default" $ | indent 6 }}
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $ | indent 6 }}
      disks:
      {{- include "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" $ | indent 6 }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- $systemdUnitValues := dict "global" $.Values.global "Template" $.Template "units" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $systemdUnitValues }}
{{- end }}
{{- if (((((($.Values.providerIntegration.controlPlane).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- $systemdUnitValues := dict "global" $.Values.global "Template" $.Template "units" $.Values.providerIntegration.controlPlane.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $systemdUnitValues }}
{{- end }}
{{- end }}

{{/* Default systemd units on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" }}
{{- if not $.Values.providerIntegration.apps.etcdDefrag.enable }}
- name: etcd3-defragmentation.service
  enabled: false
  contents: |
    [Unit]
    Description=etcd defragmentation job
    After=containerd.service kubelet.service
    Requires=containerd.service kubelet.service
    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c "crictl exec $(crictl ps --name=^etcd$ -q) etcdctl \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/peer.crt \
      --key=/etc/kubernetes/pki/etcd/peer.key \
      defrag \
      --command-timeout=60s \
      --dial-timeout=60s \
      --keepalive-timeout=25s"
- name: etcd3-defragmentation.timer
  enabled: true
  contents: |
    [Unit]
    Description=Execute etcd3-defragmentation hourly
    [Timer]
    OnCalendar=hourly
    RandomizedDelaySec=55m
    FixedRandomDelay=true
    Unit=etcd3-defragmentation.service
    [Install]
    WantedBy=multi-user.target
{{- end }}
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

{{- define "cluster.internal.controlPlane.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" }}
{{- if (((((($.Values.providerIntegration.controlPlane).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).disks }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" $.Values.providerIntegration.controlPlane.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.disks }}
{{- end }}
{{- end }}
