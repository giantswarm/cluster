{{- define "cluster.internal.kubeadm.users" }}
- name: giantswarm
  groups: sudo
  sudo: ALL=(ALL) NOPASSWD:ALL
{{- end }}
