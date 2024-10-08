{{- define "cluster.internal.workers.kubeadm.ignition" }}
containerLinuxConfig:
  additionalConfig: |-
    systemd:
      units:
      {{- $_ := set $ "nodeRole" "worker" }}
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units.default" $ | indent 6 }}
      {{- include "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $ | indent 6 }}
    storage:
      filesystems:
      {{- include "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $ | indent 6 }}
      directories:
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directorties.default" $ | indent 6 }}
      {{- include "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $ | indent 6 }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- $systemdUnitValues := dict "global" $.Values.global "Template" $.Template "units" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $systemdUnitValues }}
{{- end }}
{{- if (((((($.Values.providerIntegration.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- $systemdUnitValues := dict "global" $.Values.global "Template" $.Template "units" $.Values.providerIntegration.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $systemdUnitValues }}
{{- end }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).disks }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- if (((((($.Values.providerIntegration.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).disks }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.disks" $.Values.providerIntegration.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).filesystems }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- if (((((($.Values.providerIntegration.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).filesystems }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $.Values.providerIntegration.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" }}
{{- if ((((($.Values.providerIntegration.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).directories }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $.Values.providerIntegration.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.directories }}
{{- end }}
{{- if (((((($.Values.providerIntegration.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).directories }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $.Values.providerIntegration.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.directories }}
{{- end }}
{{- end }}
