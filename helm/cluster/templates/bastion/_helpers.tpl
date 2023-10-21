{{- define "cluster.test.bastion.machineTemplate.spec" -}}
template:
  metadata:
    cluster.x-k8s.io/role: bastion
    {{- include "cluster.labels.common" $ | nindent 4 }}
  spec:
    foo: 2
    bar: "b"
{{- end -}}
