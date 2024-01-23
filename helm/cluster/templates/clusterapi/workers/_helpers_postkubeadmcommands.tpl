{{/*
    Template cluster.internal.workers.kubeadm.postKubeadmCommands defines commands to run
    on worker nodes after kubeadm runs.

    It includes:
    - shared postKubeadmCommands that are executed on all nodes,
    - provider-specific worker commands specified in cluster-<provider> app,
    - custom cluster-specific worker commands.
*/}}
{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands" . }}
{{- include "cluster.internal.workers.kubeadm.postKubeadmCommands.provider" . }}
{{- include "cluster.internal.workers.kubeadm.postKubeadmCommands.custom" . }}
{{- end }}

{{/* Provider-specific commands to run after kubeadm on worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.workers.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run after kubeadm on worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.workers.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
