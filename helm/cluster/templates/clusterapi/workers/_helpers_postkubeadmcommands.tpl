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

{{/*
    Provider-specific commands to run after kubeadm on worker nodes.

    It includes:
    - static commands from providerIntegration.workers.kubeadmConfig.postKubeadmCommands,
    - commands rendered by the provider template named in
      providerIntegration.workers.kubeadmConfig.postKubeadmCommandsTemplateName. The template is
      rendered once per node pool with the root context, so it can use $.nodePool.name and
      $.nodePool.config to emit commands for specific node pools only.
*/}}
{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands.provider" }}
{{- range $command := $.Values.providerIntegration.workers.kubeadmConfig.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.postKubeadmCommandsTemplateName }}
{{- include $.Values.providerIntegration.workers.kubeadmConfig.postKubeadmCommandsTemplateName $ }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific commands to run after kubeadm on worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.postKubeadmCommands.custom" }}
{{- range $command := $.Values.internal.advancedConfiguration.workers.postKubeadmCommands }}
- {{ $command }}
{{- end }}
{{- end }}

{{/* Test-only provider template, used by ci/test-kubeadmcommands-templatename-values.yaml */}}
{{- define "cluster.test.workers.kubeadm.postKubeadmCommands.provider" }}
- echo "provider post command for node pool {{ $.nodePool.name }}"
{{- end }}
