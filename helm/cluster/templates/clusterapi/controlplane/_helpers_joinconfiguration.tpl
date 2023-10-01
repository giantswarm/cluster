{{- define "cluster.internal.controlPlane.kubeadm.joinConfiguration" }}
discovery: {}
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
    feature-gates: CronJobTimeZone=true
  name: ${COREOS_EC2_HOSTNAME}
  {{- if .Values.controlPlane.customNodeTaints }}
  {{- if (gt (len .Values.controlPlane.customNodeTaints) 0) }}
  taints:
  {{- range .Values.controlPlane.customNodeTaints }}
  - key: {{ .key | quote }}
    value: {{ .value | quote }}
    effect: {{ .effect | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
