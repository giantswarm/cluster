{{/*
    Template cluster.internal.workers.kubeadm.preKubeadmCommands defines commands to run
    on worker nodes before kubeadm runs.

    It includes:
    - shared preKubeadmCommands that are executed on all nodes,
    - provider-specific worker commands specified in cluster-<provider> app,
    - custom cluster-specific worker commands.
*/}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands" $ }}
{{- include "cluster.internal.workers.kubeadm.preKubeadmCommands.provider" $ }}
{{- include "cluster.internal.workers.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{/* Provider-specific commands to run before kubeadm on worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.workers.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run before kubeadm on worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.workers.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
