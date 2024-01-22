{{/*
    Template cluster.internal.controlPlane.kubeadm.preKubeadmCommands defines commands to run
    on control plane nodes before kubeadm runs.

    It includes:
    - shared preKubeadmCommands that are executed on all nodes,
    - provider-specific control plane commands specified in cluster-<provider> app,
    - custom cluster-specific control plane commands.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.provider" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{/* Provider-specific commands to run before kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.controlPlane.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run before kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.controlPlane.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}
