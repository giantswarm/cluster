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
  {{- $labels := concat (list (printf "ip=${%s}" $.Values.providerIntegration.environmentVariables.ipv4) "role=worker" (printf "giantswarm.io/machine-pool=%s-%s" (include "cluster.resource.name" $) $nodePool.name)) (or $nodePool.config.customNodeLabels list) }}
  {{- with $.Values.providerIntegration.workers.kubeadmConfig.nodeLabelsTemplateName }}
    {{- $labels = concat $labels (include . $ | fromYamlArray) }}
  {{- end }}
  - name: node-labels
    value: {{ join "," $labels }}
  - name: v
    value: "2"
  {{- $taints := concat $.Values.providerIntegration.kubeadmConfig.taints $.Values.providerIntegration.workers.kubeadmConfig.taints (or $nodePool.config.customNodeTaints list) }}
  {{- with $.Values.providerIntegration.workers.kubeadmConfig.taintsTemplateName }}
    {{- $taints = concat $taints (include . $ | fromYamlArray) }}
  {{- end }}
  {{- with $taints }}
  taints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
patches:
  directory: /etc/kubernetes/patches
{{- end }}
{{- end }}

{{/* Test-only provider template, used by `ci/test-node-labels-taints-templatename-values.yaml` */}}
{{- define "cluster.test.workers.kubeadm.nodeLabels.provider" }}
{{- if eq $.nodePool.name "pool0" }}
- provider-label=pool0
{{- end }}
{{- end }}

{{/* Test-only provider template, used by `ci/test-node-labels-taints-templatename-values.yaml` */}}
{{- define "cluster.test.workers.kubeadm.taints.provider" }}
{{- if eq $.nodePool.name "pool0" }}
- key: provider-taint
  value: pool0
  effect: NoSchedule
{{- end }}
{{- end }}
