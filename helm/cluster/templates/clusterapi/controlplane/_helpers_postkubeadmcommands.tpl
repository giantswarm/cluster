{{/*
    Template cluster.internal.controlPlane.kubeadm.postKubeadmCommands defines commands to run
    on control plane nodes after kubeadm runs.

    It includes:
    - shared postKubeadmCommands that are executed on all nodes,
    - provider-specific control plane commands specified in cluster-<provider> app,
    - custom cluster-specific control plane commands.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.postKubeadmCommands" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.provider" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.custom" $ }}
{{- end }}

{{/* Provider-specific commands to run after kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.controlPlane.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run after kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.controlPlane.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
