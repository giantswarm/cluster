{{- range $serviceAccountIssuerIndex, $serviceAccountIssuer := .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuers -}}
{{- /* First `--service-account-issuer` parameter is set in template `cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer` (see note there; avoids Kubernetes adding a default parameter) */ -}}
{{- if gt $serviceAccountIssuerIndex 0 -}}
- op: add
  path: /spec/containers/0/command/-
  value: {{ printf "--service-account-issuer=%s" (include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.serviceAccountIssuer" (dict "Values" $.Values "Release" $.Release "serviceAccountIssuer" $serviceAccountIssuer)) | quote }}
{{ end -}}
{{ end -}}
