{{- define "cluster.internal.controlPlane.kubeadm.initConfiguration" }}
skipPhases:
- addon/kube-proxy
- addon/coredns
localAPIEndpoint:
  advertiseAddress: ""
  bindPort: {{ $.Values.internal.advancedConfiguration.controlPlane.apiServer.bindPort | default 6443 }}
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
    healthz-bind-address: 0.0.0.0
    node-ip: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
    node-labels: ip={{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
    v: "2"
  name: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.hostName }}
  {{- if $.Values.global.controlPlane.customNodeTaints }}
  {{- if (gt (len $.Values.global.controlPlane.customNodeTaints) 0) }}
  taints:
  {{- range $.Values.global.controlPlane.customNodeTaints }}
  - key: {{ .key | quote }}
    value: {{ .value | quote }}
    effect: {{ .effect | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
patches:
  directory: /etc/kubernetes/patches
{{- end }}
