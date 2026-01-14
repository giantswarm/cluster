{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer" }}
certSANs:
- localhost
- 127.0.0.1
- "api.{{ include "cluster.resource.name" $ }}.{{ $.Values.global.connectivity.baseDomain }}"
- "apiserver.{{ include "cluster.resource.name" $ }}.{{ $.Values.global.connectivity.baseDomain }}"
{{- if $.Values.internal.advancedConfiguration.controlPlane.apiServer.extraCertificateSANs }}
{{ toYaml $.Values.internal.advancedConfiguration.controlPlane.apiServer.extraCertificateSANs }}
{{- end }}
{{- /*
    Timeout for the API server to appear.
    TODO: this should be aligned with alerts, i.e. time here should be less than the time after
          which we alert for API server replica being down.
*/}}
timeoutForControlPlane: 20m
extraArgs:
  {{- if .Values.internal.advancedConfiguration.controlPlane.apiServer.admissionConfiguration }}
  admission-control-config-file: /etc/kubernetes/admission/config.yaml
  {{- end }}
  {{- if .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences }}
  api-audiences: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.apiAudiences" $ | trim | quote }}
  {{- end }}
  audit-log-maxage: "30"
  audit-log-maxbackup: "30"
  audit-log-maxsize: "100"
  audit-log-path: /var/log/apiserver/audit.log
  audit-policy-file: /etc/kubernetes/policies/audit-policy.yaml
  {{- $k8sVersion := include "cluster.component.kubernetes.version" $ | trimPrefix "v" }}
  {{- if or (eq $k8sVersion "N/A") (semverCompare "<1.33.0-0" $k8sVersion) }}
  cloud-provider: external
  {{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  cloud-config: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  {{- end }}
  {{- end }}
  enable-admission-plugins: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.enableAdmissionPlugins" $ }}
  {{- if $.Values.internal.advancedConfiguration.controlPlane.apiServer.enablePriorityAndFairness }}
  enable-priority-and-fairness: "true"
  {{- end }}
  encryption-provider-config: /etc/kubernetes/encryption/config.yaml
  {{- if $.Values.internal.advancedConfiguration.controlPlane.apiServer.etcdPrefix }}
  etcd-prefix: {{ $.Values.internal.advancedConfiguration.controlPlane.apiServer.etcdPrefix }}
  {{- end }}
  {{- if include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.featureGates" $ }}
  feature-gates: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.featureGates" $ }}
  {{- end }}
  kubelet-preferred-address-types: InternalIP
  {{- if and $.Values.global.controlPlane.oidc.structuredAuthentication.enabled (ne $k8sVersion "N/A") (semverCompare ">=1.34.0-0" $k8sVersion) }}
  authentication-config: /etc/kubernetes/policies/auth-config.yaml
  {{- else }}
  {{- if $.Values.global.controlPlane.oidc.issuerUrl }}
  {{- if $.Values.global.controlPlane.oidc.caPem }}
  oidc-ca-file: /etc/ssl/certs/oidc.pem
  {{- end }}
  oidc-client-id: {{ $.Values.global.controlPlane.oidc.clientId | quote }}
  oidc-groups-claim: {{ $.Values.global.controlPlane.oidc.groupsClaim | quote }}
  {{- if $.Values.global.controlPlane.oidc.groupsPrefix }}
  oidc-groups-prefix: {{ $.Values.global.controlPlane.oidc.groupsPrefix | quote }}
  {{- end }}
  oidc-issuer-url: {{ $.Values.global.controlPlane.oidc.issuerUrl | quote }}
  oidc-username-claim: {{ $.Values.global.controlPlane.oidc.usernameClaim | quote }}
  {{- if $.Values.global.controlPlane.oidc.usernamePrefix }}
  oidc-username-prefix: {{ $.Values.global.controlPlane.oidc.usernamePrefix | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- if and $.Values.global.controlPlane.authorization.structuredAuthorization.enabled (ne $k8sVersion "N/A") (semverCompare ">=1.34.0-0" $k8sVersion) }}
  authorization-config: /etc/kubernetes/policies/authz-config.yaml
  {{- end }}
  profiling: "false"
  runtime-config: api/all=true
  {{- /* Additional `--service-account-issuer` values are applied via patch file (see `kube-apiserver1serviceaccountissuers+json.yaml.tpl`) if there are multiple such parameters. Since Kubernetes defaults to the parameter `--service-account-issuer=https://kubernetes.default.svc.cluster.local` (not desired), we must set the *first* issuer *here*. This becomes easier with the switch to v1beta4 kubeadm config which supports multiple parameters (array instead of map). */}}
  {{- if .Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuers }}
  service-account-issuer: {{ (include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.serviceAccountIssuer" (dict "Values" $.Values "Release" $.Release "serviceAccountIssuer" (.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuers | first))) | quote }}
  {{- end }}
  service-account-lookup: "true"
  service-cluster-ip-range: {{ .Values.global.connectivity.network.services.cidrBlocks | first }}
  {{- /* Returning the tls cipher suites map object use fromYamlArray when converting to string */}}
  tls-cipher-suites: {{ include "cluster.internal.kubeadm.tlsCipherSuites" $ | fromYamlArray | join "," }}
  {{- range $argName, $argValue := $.Values.internal.advancedConfiguration.controlPlane.apiServer.extraArgs }}
  {{ $argName }}: {{ if kindIs "string" $argValue }}{{ $argValue | quote }}{{ else }}{{ $argValue }}{{ end }}
  {{- end }}
extraVolumes:
- name: auditlog
  hostPath: /var/log/apiserver
  mountPath: /var/log/apiserver
  readOnly: false
  pathType: DirectoryOrCreate
{{- if .Values.internal.advancedConfiguration.controlPlane.apiServer.admissionConfiguration }}
- name: admission
  hostPath: /etc/kubernetes/admission
  mountPath: /etc/kubernetes/admission
  readOnly: true
  pathType: Directory
{{- end }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig }}
- name: cloud-config
  hostPath: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  mountPath: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  readOnly: true
{{- end }}
- name: policies
  hostPath: /etc/kubernetes/policies
  mountPath: /etc/kubernetes/policies
  readOnly: false
  pathType: DirectoryOrCreate
- name: encryption
  hostPath: /etc/kubernetes/encryption
  mountPath: /etc/kubernetes/encryption
  readOnly: false
  pathType: DirectoryOrCreate
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.apiAudiences" }}
{{- if ($.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences).value }}
{{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences.value | trim }}
{{- else if ($.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences).templateName }}
{{ include $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.apiAudiences.templateName $ | trim }}
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.enableAdmissionPlugins" }}
{{- $defaultPlugins := list
  "DefaultStorageClass"
  "DefaultTolerationSeconds"
  "LimitRanger"
  "MutatingAdmissionWebhook"
  "NamespaceLifecycle"
  "NodeRestriction"
  "OwnerReferencesPermissionEnforcement"
  "PersistentVolumeClaimResize"
  "Priority"
  "ResourceQuota"
  "ServiceAccount"
  "ValidatingAdmissionWebhook" -}}
{{- $providerPlugins := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.additionalAdmissionPlugins | default list }}
{{- $internalPlugins := $.Values.internal.advancedConfiguration.controlPlane.apiServer.additionalAdmissionPlugins | default list }}
{{- concat $defaultPlugins $providerPlugins $internalPlugins | compact | uniq | join "," }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.serviceAccountIssuer" }}
{{- if .serviceAccountIssuer.clusterDomainPrefix -}}
https://{{ .serviceAccountIssuer.clusterDomainPrefix }}.{{ include "cluster.resource.name" $ }}.{{ $.Values.global.connectivity.baseDomain }}
{{- else if .serviceAccountIssuer.templateName -}}
{{- include .serviceAccountIssuer.templateName $ -}}
{{- else -}}
{{ .serviceAccountIssuer.url }}
{{- end }}
{{- end }}

{{- define "cluster.test.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiServer.apiAudiences" }}
api-audiences-example.giantswarm.io
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.apiServer.featureGates" }}
{{- $kubernetesVersion := include "cluster.component.kubernetes.version" $ }}
{{- $providerFeatureGates := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.featureGates }}
{{- $internalFeatureGates := $.Values.internal.advancedConfiguration.controlPlane.apiServer.featureGates }}
{{- $_ := include "cluster.internal.get-internal-values" $ }}
{{- $renderWithoutRelease := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" (dict "providerFeatureGates" $providerFeatureGates "internalFeatureGates" $internalFeatureGates "kubernetesVersion" $kubernetesVersion "renderWithoutReleaseResource" $renderWithoutRelease) }}
{{- end }}
