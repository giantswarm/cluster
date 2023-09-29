{{- define "cluster.internal.controlPlane.kubeadm.initConfiguration" }}
skipPhases:
- addon/kube-proxy
- addon/coredns
localAPIEndpoint:
  advertiseAddress: ""
  bindPort: 0
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
    feature-gates: CronJobTimeZone=true
    healthz-bind-address: 0.0.0.0
    node-ip: ${COREOS_EC2_IPV4_LOCAL}
    v: "2"
  name: ${COREOS_EC2_HOSTNAME}
  {{- if $.Values.controlPlane.customNodeTaints }}
  {{- if (gt (len .Values.controlPlane.customNodeTaints) 0) }}
  taints:
  {{- range $.Values.controlPlane.customNodeTaints }}
  - key: {{ .key | quote }}
    value: {{ .value | quote }}
    effect: {{ .effect | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
