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

{{/*
    Provider-specific commands to run after kubeadm on control plane nodes.

    It includes:
    - static commands from providerIntegration.controlPlane.kubeadmConfig.postKubeadmCommands,
    - commands rendered by the provider template named in
      providerIntegration.controlPlane.kubeadmConfig.postKubeadmCommandsTemplateName. The template is
      rendered once with the root context. There is no node pool in this context, so the template
      must not read $.nodePool.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.controlPlane.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.postKubeadmCommandsTemplateName }}
{{- include $.Values.providerIntegration.controlPlane.kubeadmConfig.postKubeadmCommandsTemplateName $ }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run after kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.postKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.controlPlane.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Test-only provider template, used by ci/test-kubeadmcommands-templatename-values.yaml */}}
{{- define "cluster.test.controlPlane.kubeadm.postKubeadmCommands.provider" }}
- echo "provider post command for control plane"
{{- end }}
