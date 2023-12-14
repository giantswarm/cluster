{{- define "cluster.internal.workers.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.workers.kubeadm.files.custom" $ }}
{{- end }}

{{- define "cluster.internal.workers.kubeadm.files.custom" }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.files }}
{{ toYaml $.Values.providerIntegration.workers.kubeadmConfig.files }}
{{- end }}
{{- end }}
