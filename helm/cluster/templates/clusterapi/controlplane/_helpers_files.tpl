{{- define "cluster.internal.controlPlane.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.admission" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.audit" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.encryption" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.fairness" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.oidc" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.provider" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.custom" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.files.cloudConfig" $ }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.cloudConfig" }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
- path:  {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-control-plane-{{ include "cluster.data.hash" (dict "data" (include $.Values.providerIntegration.controlPlane.resources.infrastructureMachineTemplateSpecTemplateName $) "salt" $.Values.providerIntegration.hashSalt) }}-{{ include $.Values.providerIntegration.provider }}-json
      key: control-plane-{{ include $.Values.providerIntegration.provider }}.json
      owner: root:root
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.admission" }}
{{- with .Values.internal.advancedConfiguration.controlPlane.apiServer.admissionConfiguration }}
- path: /etc/kubernetes/admission/config.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/kubernetes/admission/config.yaml") $ | b64enc }}
{{- if .plugins }}
{{- range .plugins }}
- path: /etc/kubernetes/admission/plugins/{{ .name | lower }}.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl .config $ | b64enc }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.audit" }}
- path: /etc/kubernetes/policies/audit-policy.yaml
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/kubernetes/policies/audit-policy.yaml") . | b64enc }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.encryption" }}
- path: /etc/kubernetes/encryption/config.yaml
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-encryption-provider-config
      key: encryption
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.fairness" }}
{{- if $.Values.internal.advancedConfiguration.controlPlane.apiServer.enablePriorityAndFairness }}
- path: /opt/bin/configure-apiserver-fairness.sh
  permissions: "0755"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/opt/bin/configure-apiserver-fairness.sh") . | b64enc }}
- path: /etc/kubernetes/patches/kube-apiserver0+json.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/kubernetes/patches/kube-apiserver0+json.yaml") . | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.files.oidc" }}
{{- if $.Values.global.controlPlane.oidc.caPem }}
- path: /etc/ssl/certs/oidc.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssl/certs/oidc.pem") . | b64enc }}
{{- end }}
{{- end }}

{{/* Provider-specific files for control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.files.provider" }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.providerIntegration.controlPlane.kubeadmConfig.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}

{{/* Custom cluster-specific files for control plane nodes */}}
{{- define "cluster.internal.controlPlane.kubeadm.files.custom" }}
{{- if $.Values.internal.advancedConfiguration.controlPlane.files }}
{{ include "cluster.internal.processFiles" (dict "files" $.Values.internal.advancedConfiguration.controlPlane.files "clusterName" (include "cluster.resource.name" $)) }}
{{- end }}
{{- end }}
