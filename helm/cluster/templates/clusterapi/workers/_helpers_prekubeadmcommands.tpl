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

{{/*
    Provider-specific commands to run before kubeadm on worker nodes.

    It includes:
    - static commands from providerIntegration.workers.kubeadmConfig.preKubeadmCommands,
    - commands rendered by the provider template named in
      providerIntegration.workers.kubeadmConfig.preKubeadmCommandsTemplateName. The template is
      rendered once per node pool with the root context, so it can use $.nodePool.name and
      $.nodePool.config to emit commands for specific node pools only.
*/}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.workers.kubeadmConfig.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.preKubeadmCommandsTemplateName }}
{{- include $.Values.providerIntegration.workers.kubeadmConfig.preKubeadmCommandsTemplateName $ }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run before kubeadm on worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.workers.preKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Test-only provider template, used by ci/test-prekubeadmcommands-templatename-values.yaml */}}
{{- define "cluster.test.workers.kubeadm.preKubeadmCommands.provider" }}
- echo "provider command for node pool {{ $.nodePool.name }}"
{{- end }}
