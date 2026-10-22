{{- define "cluster.internal.workers.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.workers.kubeadm.files.provider" $ }}
{{- include "cluster.internal.workers.kubeadm.files.custom" $ }}
{{- include "cluster.internal.workers.kubeadm.files.kernel" $ }}
{{- include "cluster.internal.workers.kubeadm.files.cloudConfig" $ }}
{{- end }}

{{/* Provider-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.provider" }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.providerIntegration.workers.kubeadmConfig.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- if $.Values.providerIntegration.workers.kubeadmConfig.filesTemplateName }}
{{- $files := include $.Values.providerIntegration.workers.kubeadmConfig.filesTemplateName $ | fromYamlArray }}
{{- if $files }}
{{ include "cluster.internal.processFiles" (dict "files" $files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.workers.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.internal.advancedConfiguration.workers.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}

{{/* Node pool kernel configuration files for worker nodes */}}
{{- define "cluster.internal.workers.kubeadm.files.kernel" }}
{{- with $.nodePool.config.kernel }}
{{- if .sysctls }}
- path: /etc/sysctl.d/90-node-pool.conf
  permissions: "0644"
  content: |
    {{- range $key, $value := .sysctls }}
    {{ $key }} = {{ if kindIs "float64" $value }}{{ $value | int64 }}{{ else }}{{ $value }}{{ end }}
    {{- end }}
{{- end }}
{{- if .sysfs }}
{{- /* tmpfiles.d interprets backslash escapes and % specifiers in the argument field. */}}
- path: /etc/tmpfiles.d/00-node-pool.conf
  permissions: "0644"
  content: |
    {{- range $path, $value := .sysfs }}
    w {{ $path }} - - - - {{ if kindIs "float64" $value }}{{ $value | int64 }}{{ else }}{{ $value | toString | replace "\\" "\\\\" | replace "%" "%%" }}{{ end }}
    {{- end }}
{{- end }}
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

{{/* Test-only provider template, used by `ci/test-files-templatename-values.yaml` */}}
{{- define "cluster.test.workers.kubeadm.files.provider" }}
{{- if eq $.nodePool.name "pool0" }}
- path: /etc/provider-file-for-node-pool-{{ $.nodePool.name }}.conf
  permissions: "0644"
  contentFrom:
    secret:
      name: provider-file
      key: provider-file.conf
      prependClusterNameAsPrefix: true
{{- end }}
{{- end }}
