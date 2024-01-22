{{- define "cluster.internal.workers.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.workers.kubeadm.files.custom" $ }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.workers.files }}
{{ toYaml $.Values.internal.advancedConfiguration.workers.files }}
{{- end }}
{{- end }}
