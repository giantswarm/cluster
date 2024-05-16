{{- define "cluster.internal.workers.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.workers.kubeadm.files.provider" $ }}
{{- include "cluster.internal.workers.kubeadm.files.custom" $ }}
{{- include "cluster.internal.workers.kubeadm.files.cloudConfig" $ }}
{{- end }}

{{/* Provider-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.provider" }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.providerIntegration.workers.kubeadmConfig.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.workers.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.internal.advancedConfiguration.workers.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}

{{/* CloudConfig cluster-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.cloudConfig" }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
{{- $_ := set $ "osImage" $.Values.providerIntegration.osImage }}
{{- $_ = set $ "kubernetesVersion" $.Values.providerIntegration.kubernetesVersion }}
- path:  {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-{{ .nodePool.name }}-{{ include "cluster.data.hash" (dict "data" (include $.Values.providerIntegration.workers.resources.infrastructureMachineTemplateSpecTemplateName $) "salt" $.Values.providerIntegration.hashSalt) }}-{{ $.Values.providerIntegration.provider }}-json
      key: worker-node-{{ $.Values.providerIntegration.provider }}.json
      owner: root:root
{{- end }}
{{- end }}
