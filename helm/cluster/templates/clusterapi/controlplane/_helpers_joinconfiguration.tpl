{{- define "cluster.internal.controlPlane.kubeadm.joinConfiguration" }}
discovery: {}
controlPlane:
  localAPIEndpoint:
    bindPort: {{ $.Values.internal.advancedConfiguration.controlPlane.apiServer.bindPort | default 6443 }}
nodeRegistration:
  kubeletExtraArgs:
    {{- if $.Values.internal.advancedConfiguration.cgroupsv1 }}
    cgroup-driver: cgroupfs
    {{- end }}
    cloud-provider: external
    feature-gates: CronJobTimeZone=true
    node-ip: ${COREOS_EC2_IPV4_LOCAL}
  name: ${COREOS_EC2_HOSTNAME}
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
{{- end }}
