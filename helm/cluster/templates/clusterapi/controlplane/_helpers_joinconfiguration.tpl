{{- define "cluster.internal.controlPlane.kubeadm.joinConfiguration" }}
discovery: {}
controlPlane:
  localAPIEndpoint:
    bindPort: {{ $.Values.internal.controlPlane.kubeadmConfig.localAPIEndpoint.bindPort }}
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
    feature-gates: CronJobTimeZone=true
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
