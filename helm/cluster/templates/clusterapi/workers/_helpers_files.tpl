{{- define "cluster.internal.workers.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.workers.kubeadm.files.provider" $ }}
{{- include "cluster.internal.workers.kubeadm.files.custom" $ }}
{{- end }}

{{/* Provider-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.provider" }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.files }}
{{ toYaml $.Values.providerIntegration.workers.kubeadmConfig.files }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.workers.files }}
{{ toYaml $.Values.internal.advancedConfiguration.workers.files }}
{{- end }}
{{- end }}
