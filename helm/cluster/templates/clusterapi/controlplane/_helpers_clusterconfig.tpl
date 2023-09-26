{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.oidc" }}
{{- with $oidc := .Values.controlPlane.oidc }}
oidc-issuer-url: {{ $oidc.issuerUrl }}
oidc-client-id: {{ $oidc.clientId }}
oidc-username-claim: {{ $oidc.usernameClaim }}
oidc-groups-claim: {{ $oidc.groupsClaim }}
{{- if $oidc.caPem }}
oidc-ca-file: /etc/ssl/certs/oidc.pem
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.serviceAccountIssuer" }}
{{- if .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.clusterDomainPrefix -}}
https://{{ .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.clusterDomainPrefix }}.{{ include "resource.default.name" $ }}.{{ required "The baseDomain value is required" .Values.connectivity.baseDomain }}
{{- else -}}
{{ .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.url }}
{{- end }}
{{- end }}
