{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer" }}
certSANs:
- localhost
- 127.0.0.1
- "api.{{ include "cluster.resource.name" $ }}.{{ required "The baseDomain value is required" $.Values.global.connectivity.baseDomain }}"
- "apiserver.{{ include "cluster.resource.name" $ }}.{{ required "The baseDomain value is required" $.Values.global.connectivity.baseDomain }}"
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.extraCertificateSANs }}
{{ toYaml $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.extraCertificateSANs }}
{{- end }}
{{- /*
    Timeout for the API server to appear.
    TODO: this should be aligned with alerts, i.e. time here should be less than the time after
          which we alert for API server replica being down.
*/}}
timeoutForControlPlane: 20min
extraArgs:
  {{- if .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences }}
  api-audiences: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.apiAudiences" $ | trim | quote }}
  {{- end }}
  audit-log-maxage: "30"
  audit-log-maxbackup: "30"
  audit-log-maxsize: "100"
  audit-log-path: /var/log/apiserver/audit.log
  audit-policy-file: /etc/kubernetes/policies/audit-policy.yaml
  cloud-provider: external
  enable-admission-plugins: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.enableAdmissionPlugins" $ }}
  encryption-provider-config: /etc/kubernetes/encryption/config.yaml
  {{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.etcdPrefix }}
  etcd-prefix: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.etcdPrefix }}
  {{- end }}
  {{- if .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.featureGates }}
  feature-gates: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.featureGates" $ }}
  {{- end }}
  kubelet-preferred-address-types: InternalIP
  {{- if $.Values.global.controlPlane.oidc.issuerUrl }}
  {{- if $.Values.global.controlPlane.oidc.caPem }}
  oidc-ca-file: /etc/ssl/certs/oidc.pem
  {{- end }}
  oidc-client-id: {{ $.Values.global.controlPlane.oidc.clientId | quote }}
  oidc-groups-claim: {{ $.Values.global.controlPlane.oidc.groupsClaim | quote }}
  oidc-issuer-url: {{ $.Values.global.controlPlane.oidc.issuerUrl | quote }}
  oidc-username-claim: {{ $.Values.global.controlPlane.oidc.usernameClaim | quote }}
  {{- end }}
  profiling: "false"
  runtime-config: api/all=true
  {{- if .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer }}
  service-account-issuer: "{{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.serviceAccountIssuer" $ }}"
  {{- end }}
  service-account-lookup: "true"
  service-cluster-ip-range: {{ .Values.global.connectivity.network.services.cidrBlocks | first }}
  tls-cipher-suites: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.tlsCipherSuites" $ }}
  {{- range $argName, $argValue := ((($.Values.providerIntegration.controlPlane.kubeadmConfig).clusterConfiguration).apiServer).extraArgs }}
  {{ $argName }}: {{ if kindIs "string" $argValue }}{{ $argValue | quote }}{{ else }}{{ $argValue }}{{ end }}
  {{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.apiAudiences" }}
{{- if kindIs "string" $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences }}
{{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences | trim }}
{{- else if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences.templateName }}
{{ include $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences.templateName $ | trim }}
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.enableAdmissionPlugins" }}
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
{{- range $additionalAdmissionPlugin := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.additionalAdmissionPlugins }}
{{- $enabledAdmissionPlugins = append $enabledAdmissionPlugins $additionalAdmissionPlugin -}}
{{- end }}
{{- join "," (compact $enabledAdmissionPlugins) }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.serviceAccountIssuer" }}
{{- if .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.clusterDomainPrefix -}}
https://{{ .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.clusterDomainPrefix }}.{{ include "cluster.resource.name" $ }}.{{ required "The baseDomain value is required" $.Values.global.connectivity.baseDomain }}
{{- else -}}
{{ .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.url }}
{{- end }}
{{- end }}

{{- define "cluster.test.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.apiAudiences" }}
api-audiences-example.giantswarm.io
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.tlsCipherSuites" }}
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
{{- range $featureGate := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.featureGates }}
{{- $featureGates = append $featureGates (printf "%s=%t" $featureGate.name $featureGate.enabled) -}}
{{- end }}
{{- join "," (compact $featureGates) | quote }}
{{- end }}
