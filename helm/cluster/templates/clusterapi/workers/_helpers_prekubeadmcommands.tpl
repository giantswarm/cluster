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
{{- include "cluster.internal.workers.kubeadm.preKubeadmCommands.localEphemeralStorage" $ }}
{{- include "cluster.internal.workers.kubeadm.preKubeadmCommands.custom" $ }}
{{- end }}

{{/*
    Self-gating local instance-store NVMe mount + nodefs.available backstop.
    Rendered once (cluster-wide worker bootstrap) when any node pool opts in via
    localNvme.enabled; the script itself no-ops on nodes without instance store.
*/}}
{{- define "cluster.internal.workers.kubeadm.preKubeadmCommands.localEphemeralStorage" }}
{{- if eq (include "cluster.internal.workers.localEphemeralStorage.enabled" $) "true" }}
{{- $les := $.Values.internal.advancedConfiguration.workers.localEphemeralStorage }}
{{- $script := include "cluster.internal.workers.localEphemeralStorage.script" $les | b64enc }}
- "echo '{{ $script }}' | base64 -d > /opt/bin/setup-local-nvme.sh; chmod +x /opt/bin/setup-local-nvme.sh; /opt/bin/setup-local-nvme.sh"
{{- end }}
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
