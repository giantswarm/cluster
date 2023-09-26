{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.serviceAccountIssuer" }}
{{- if .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.clusterDomainPrefix -}}
https://{{ .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.clusterDomainPrefix }}.{{ include "resource.default.name" $ }}.{{ required "The baseDomain value is required" .Values.connectivity.baseDomain }}
{{- else -}}
{{ .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.URL }}
{{- end }}
{{- end }}
