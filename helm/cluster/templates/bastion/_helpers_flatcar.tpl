{{- define "cluster.internal.bastion.kubeadm.ignition" }}
containerLinuxConfig:
  additionalConfig: |
    systemd:
      {{- if (((((($.Values.providerIntegration.bastion).kubeadmConfig).ignition).containerLinuxConfig).additionalConfig).systemd).units }}
      units:
      {{- include "cluster.internal.kubeadm.ignition.containerLinuxConfig.additionalConfig.systemd.units" $.Values.providerIntegration.bastion.kubeadmConfig.ignition.containerLinuxConfig.additionalConfig.systemd.units | indent 6 }}
      {{- else }}
      units: []
      {{- end }}
{{- end }}
