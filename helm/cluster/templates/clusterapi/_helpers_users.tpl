{{- define "cluster.internal.kubeadm.users" }}
{{- if $.Values.providerIntegration.resourcesApi.bastionResourceEnabled }}
{{- if .Values.global.connectivity.bastion.enabled }}
- name: giantswarm
  groups: sudo
  sudo: ALL=(ALL) NOPASSWD:ALL
{{- end }}
{{- end }}
{{- end }}
