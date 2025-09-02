{{/*
  Named template that renders join configuration for worker nodes.

  Template argument is a dictinary with the following values:
    .name: Node pool name, a key from $.Values.global.nodepools map.
    .config: node pool config, a value from $.Values.global.nodepools map.
*/}}
{{- define "cluster.internal.workers.kubeadm.joinConfiguration" }}
{{- with $nodePool := required "nodePool must be set" .nodePool }}
nodeRegistration:
  name: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.hostName }}
  kubeletExtraArgs:
    {{- if or $nodePool.config.cgroupsv1 $.Values.internal.advancedConfiguration.cgroupsv1 }}
    cgroup-driver: cgroupfs
    {{- end }}
    cloud-provider: external
    {{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
    cloud-config: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
    {{- end }}
    healthz-bind-address: 0.0.0.0
    node-ip: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
    node-labels: ip={{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }},role=worker,giantswarm.io/machine-pool={{ include "cluster.resource.name" $ }}-{{ $nodePool.name }}{{- if $nodePool.config.customNodeLabels }},{{ join "," $nodePool.config.customNodeLabels }}{{- end }}
    v: "2"
  {{- $taints := concat $.Values.providerIntegration.kubeadmConfig.taints $.Values.providerIntegration.workers.kubeadmConfig.taints (or $nodePool.config.customNodeTaints list) }}
  {{- if eq $nodePool.config.type "karpenter" }}
    {{- $taints = append $taints (dict "key" "karpenter.sh/unregistered" "effect" "NoExecute" "value" "karpenter") }}
  {{- end }}
  {{- with $taints }}
  taints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
patches:
  directory: /etc/kubernetes/patches
{{- end }}
{{- end }}
