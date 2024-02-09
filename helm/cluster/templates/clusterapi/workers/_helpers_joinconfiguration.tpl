{{/*
  Named template that renders join configuration for worker nodes.

  Template argument is a dictinary with the following values:
    .name: Node pool name, a key from $.Values.global.nodepools map.
    .config: node pool config, a value from $.Values.global.nodepools map.
*/}}
{{- define "cluster.internal.workers.kubeadm.joinConfiguration" }}
{{- with $nodePool := required "nodePool must be set" .nodePool }}
nodeRegistration:
  name: ${COREOS_EC2_HOSTNAME}
  kubeletExtraArgs:
    {{- if $.Values.internal.advancedConfiguration.cgroupsv1 }}
    cgroup-driver: cgroupfs
    {{- end }}
    cloud-provider: external
    feature-gates: CronJobTimeZone=true
    healthz-bind-address: 0.0.0.0
    node-ip: ${COREOS_EC2_IPV4_LOCAL}
    node-labels: role=worker,giantswarm.io/machine-pool={{ include "cluster.resource.name" $ }}-{{ $nodePool.name }},{{- join "," $nodePool.config.customNodeLabels }}
    v: "2"
  {{- if $nodePool.config.customNodeTaints }}
  taints:
  {{- range $nodePool.config.customNodeTaints }}
  - key: {{ .key | quote }}
    value: {{ .value | quote }}
    effect: {{ .effect | quote }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
