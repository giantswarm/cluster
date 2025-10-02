{{- define "cluster.internal.controlPlane.kubeadm.initConfiguration" }}
skipPhases:
- addon/kube-proxy
- addon/coredns
localAPIEndpoint:
  advertiseAddress: ""
  bindPort: {{ $.Values.internal.advancedConfiguration.controlPlane.apiServer.bindPort | default 6443 }}
nodeRegistration:
  kubeletExtraArgs:
    {{- $k8sVersion := include "cluster.component.kubernetes.version" $ | trimPrefix "v" }}
    {{- if or (eq $k8sVersion "N/A") (semverCompare "<1.33.0-0" $k8sVersion) }}
    cloud-provider: external
    {{- end }}
    cgroup-driver: systemd
    healthz-bind-address: 0.0.0.0
    node-ip: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
    node-labels: ip={{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
    v: "2"
    register-with-taints: 'node-role.kubernetes.io/control-plane="":NoSchedule'
  name: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.hostName }}
  {{- with (concat $.Values.providerIntegration.kubeadmConfig.taints $.Values.providerIntegration.controlPlane.kubeadmConfig.taints $.Values.global.controlPlane.customNodeTaints ) }}
  taints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
patches:
  directory: /etc/kubernetes/patches
{{- end }}
