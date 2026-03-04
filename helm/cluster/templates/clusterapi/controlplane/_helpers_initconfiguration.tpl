{{- define "cluster.internal.controlPlane.kubeadm.initConfiguration" }}
skipPhases:
- addon/kube-proxy
- addon/coredns
localAPIEndpoint:
  advertiseAddress: ""
  bindPort: {{ $.Values.internal.advancedConfiguration.controlPlane.apiServer.bindPort | default 6443 }}
nodeRegistration:
  kubeletExtraArgs:
  - name: cloud-provider
    value: external
  - name: cgroup-driver
    value: systemd
  - name: healthz-bind-address
    value: 0.0.0.0
  - name: node-ip
    value: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
  - name: node-labels
    value: ip={{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
  - name: v
    value: "2"
  - name: register-with-taints
    value: 'node-role.kubernetes.io/control-plane="":NoSchedule'
  name: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.hostName }}
  {{- with (concat $.Values.providerIntegration.kubeadmConfig.taints $.Values.providerIntegration.controlPlane.kubeadmConfig.taints $.Values.global.controlPlane.customNodeTaints ) }}
  taints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
patches:
  directory: /etc/kubernetes/patches
{{- end }}
