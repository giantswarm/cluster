{{- define "cluster.internal.workers.kubeadm.ignition" }}
containerLinuxConfig:
  additionalConfig: |
    systemd:
      units:
      {{- include "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $ | indent 6 }}
    storage:
      directories:
      {{- include "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $ | indent 6 }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" }}
{{- if ((((($.Values.internal.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $.Values.internal.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- end }}
{{- if (((((($.Values.internal.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $.Values.internal.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units }}
{{- end }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" }}
{{- if ((((($.Values.internal.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).filesystems }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $.Values.internal.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- if (((((($.Values.internal.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).filesystems }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.filesystems" $.Values.internal.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.filesystems }}
{{- end }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" }}
{{- if ((((($.Values.internal.kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).directories }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $.Values.internal.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.directories }}
{{- end }}
{{- if (((((($.Values.internal.workers).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).storage).directories }}
{{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.storage.directories" $.Values.internal.workers.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.storage.directories }}
{{- end }}
{{- end }}