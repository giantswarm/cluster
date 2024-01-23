{{/*
    Template cluster.internal.kubeadm.postKubeadmCommands defines common commands to run on all
    (control plane and workers) nodes after kubeadm runs.

    It includes:
    - provider-specific commands specified in cluster-<provider> app,
    - custom cluster-specific commands.
*/}}
{{- define "cluster.internal.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands.provider" $ }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands.custom" $ }}
{{- end }}

{{/* Provider-specific commands to run after kubeadm on all nodes */}}
{{- define "cluster.internal.kubeadm.postKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run after kubeadm on all nodes */}}
{{- define "cluster.internal.kubeadm.postKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
