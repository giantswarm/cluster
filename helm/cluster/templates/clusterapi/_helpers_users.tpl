{{- define "cluster.internal.kubeadm.users" }}
{{- if or (and $.Values.providerIntegration.resourcesApi.bastionResourceEnabled .Values.global.connectivity.bastion.enabled) $.Values.providerIntegration.kubeadmConfig.users }}
- name: giantswarm
  groups: sudo
  sudo: ALL=(ALL) NOPASSWD:ALL
{{- end }}
{{- end }}
