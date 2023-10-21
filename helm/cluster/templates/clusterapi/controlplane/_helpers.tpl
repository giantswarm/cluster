{{- define "cluster.internal.test.controlPlane.machineTemplate.spec" -}}
template:
  metadata:
    cluster.x-k8s.io/role: controlPlane
    {{- include "cluster.labels.common" $ | nindent 4 }}
  spec:
    machineType: "superBig"
{{- end -}}
