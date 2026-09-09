{{/*
    Template cluster.internal.controlPlane.kubeadm.preKubeadmCommands defines commands to run
    on control plane nodes before kubeadm runs.

    It includes:
    - shared preKubeadmCommands that are executed on all nodes,
    - custom cluster-specific control plane commands.
    - provider-specific control plane commands specified in cluster-<provider> app,

    For CAPA migration custom preKubeadmCommands have to be before any other commands.
*/}}

{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.custom" $ }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.default" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.provider" $ }}
{{- end }}

{{/* Default commands to run before kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.default" }}
{{- if $.Values.internal.advancedConfiguration.controlPlane.apiServer.enablePriorityAndFairness }}
- /opt/bin/configure-apiserver-fairness.sh
{{- end }}
{{- end }}

{{/*
    Provider-specific commands to run before kubeadm on control plane nodes.

    It includes:
    - static commands from providerIntegration.controlPlane.kubeadmConfig.preKubeadmCommands,
    - commands rendered by the provider template named in
      providerIntegration.controlPlane.kubeadmConfig.preKubeadmCommandsTemplateName. The template is
      rendered once with the root context. There is no node pool in this context, so the template
      must not read $.nodePool.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.controlPlane.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.preKubeadmCommandsTemplateName }}
{{- include $.Values.providerIntegration.controlPlane.kubeadmConfig.preKubeadmCommandsTemplateName $ }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run before kubeadm on control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.preKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.controlPlane.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Test-only provider template, used by ci/test-kubeadmcommands-templatename-values.yaml */}}
{{- define "cluster.test.controlPlane.kubeadm.preKubeadmCommands.provider" }}
- echo "provider pre command for control plane"
{{- end }}
