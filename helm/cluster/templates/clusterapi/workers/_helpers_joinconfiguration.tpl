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
  - name: cgroup-driver
    value: systemd
  - name: cloud-provider
    value: external
  {{- $k8sVersion := include "cluster.component.kubernetes.version" $ | trimPrefix "v" }}
  {{- if or (eq $k8sVersion "N/A") (semverCompare "<1.34.0-0" $k8sVersion) }}
  {{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  - name: cloud-config
    value: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  {{- end }}
  {{- end }}
  - name: healthz-bind-address
    value: 0.0.0.0
  - name: node-ip
    value: {{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }}
  {{- /*
    On Karpenter node pools, `karpenter.sh/do-not-sync-taints=true` stops Karpenter from copying the NodePool
    taints and startup taints onto the Node, which races with agents removing their startup taints.
    See https://github.com/kubernetes-sigs/karpenter/issues/1772
  */}}
  - name: node-labels
    value: ip={{ printf "${%s}" $.Values.providerIntegration.environmentVariables.ipv4 }},role=worker,giantswarm.io/machine-pool={{ include "cluster.resource.name" $ }}-{{ $nodePool.name }}{{- if $nodePool.config.customNodeLabels }},{{ join "," $nodePool.config.customNodeLabels }}{{- end }}{{- if eq $nodePool.config.type "karpenter" }},karpenter.sh/do-not-sync-taints=true{{- end }}
  - name: v
    value: "2"
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
