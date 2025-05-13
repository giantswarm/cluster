{{- define "cluster.internal.controlPlane.kubeadm.joinConfiguration" }}
discovery: {}
controlPlane:
  localAPIEndpoint:
    bindPort: {{ $.Values.internal.advancedConfiguration.controlPlane.apiServer.bindPort | default 6443 }}
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
    node-ip: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
    node-labels: ip={{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
  name: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.hostName }}
  {{- with (concat $.Values.providerIntegration.kubeadmConfig.taints $.Values.providerIntegration.controlPlane.kubeadmConfig.taints $.Values.global.controlPlane.customNodeTaints ) }}
  taints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
patches:
  directory: /etc/kubernetes/patches
{{- end }}
