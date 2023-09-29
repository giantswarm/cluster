{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.enableAdmissionPlugins" }}
{{- $enabledAdmissionPlugins := list
  "DefaultStorageClass"
  "DefaultTolerationSeconds"
  "LimitRanger"
  "MutatingAdmissionWebhook"
  "NamespaceLifecycle"
  "PersistentVolumeClaimResize"
  "Priority"
  "ResourceQuota"
  "ServiceAccount"
  "ValidatingAdmissionWebhook" -}}
{{- range $additionalAdmissionPlugin := $.Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.additionalAdmissionPlugins }}
{{- $enabledAdmissionPlugins = append $enabledAdmissionPlugins $additionalAdmissionPlugin -}}
{{- end }}
{{- join "," (compact $enabledAdmissionPlugins) }}
{{- end }}

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

{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.apiAudiences" }}
{{- if kindIs "string" $.Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences }}
api-audiences: "{{ $.Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences | trim }}"
{{- else if $.Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences.templateName }}
api-audiences: "{{ include $.Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences.templateName $ | trim }}"
{{- end }}
{{- end }}

{{- define "cluster.test.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.apiAudiences" }}
api-audiences-example.giantswarm.io
{{- end }}

{{- define "cluster.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.tlsCipherSuites" }}
{{- $preferredCiphers := list
  "TLS_AES_128_GCM_SHA256"
  "TLS_AES_256_GCM_SHA384"
  "TLS_CHACHA20_POLY1305_SHA256"
  "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA"
  "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
  "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA"
  "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
  "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
  "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
  "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"
  "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
  "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
  "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
  "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
  "TLS_RSA_WITH_AES_128_CBC_SHA"
  "TLS_RSA_WITH_AES_128_GCM_SHA256"
  "TLS_RSA_WITH_AES_256_CBC_SHA"
  "TLS_RSA_WITH_AES_256_GCM_SHA384"
-}}
{{- join "," (compact $preferredCiphers) }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.featureGates" }}
{{- $featureGates := list -}}
{{- range $featureGate := $.Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.featureGates }}
{{- $featureGates = append $featureGates (printf "%s=%t" $featureGate.name $featureGate.enabled) -}}
{{- end }}
{{- join "," (compact $featureGates) | quote }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer" }}
{{- if .Values.internal.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.featureGates }}
feature-gates: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.featureGates" $ }}
{{- end}}
{{- end }}
