{{- /* Hardened according to https://kubernetes.io/docs/concepts/security/hardening-guide/scheduler/. `bind-address` and `/metrics` in `authorization-always-allow-paths` intentionally deviate from the guide, as control plane metrics are scraped over the network. */}}
{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler" }}
extraArgs:
- name: authentication-skip-lookup
  value: "false"
- name: authentication-tolerate-lookup-failure
  value: "false"
- name: authorization-always-allow-paths
  value: "/healthz,/readyz,/livez,/metrics"
- name: bind-address
  value: 0.0.0.0
{{- if include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" $ }}
- name: feature-gates
  value: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" $ }}
{{- end }}
- name: permit-address-sharing
  value: "false"
- name: permit-port-sharing
  value: "false"
- name: profiling
  value: "false"
{{- /* Returning the tls cipher suites map object use fromYamlArray when converting to string */}}
- name: tls-cipher-suites
  value: {{ include "cluster.internal.kubeadm.tlsCipherSuites" $ | fromYamlArray | join "," }}
{{- end }}

{{- /* Hardening flags for the scheduler of a KamajiControlPlane, in Kamaji's `--flag=value` format. Rendered before the provider's `extraArgs`, so providers can still override them. */}}
{{- define "cluster.internal.controlPlane.kamaji.scheduler.hardeningArgs" }}
- --authentication-skip-lookup=false
- --authentication-tolerate-lookup-failure=false
- --permit-address-sharing=false
- --permit-port-sharing=false
- --profiling=false
- --tls-cipher-suites={{ include "cluster.internal.kubeadm.tlsCipherSuites" $ | fromYamlArray | join "," }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" }}
{{- $kubernetesVersion := include "cluster.component.kubernetes.version" $ }}
{{- $providerFeatureGates := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.scheduler.featureGates }}
{{- $internalFeatureGates := $.Values.internal.advancedConfiguration.controlPlane.scheduler.featureGates }}
{{- $_ := include "cluster.internal.get-internal-values" $ }}
{{- $renderWithoutRelease := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" (dict "providerFeatureGates" $providerFeatureGates "internalFeatureGates" $internalFeatureGates "kubernetesVersion" $kubernetesVersion "renderWithoutReleaseResource" $renderWithoutRelease) }}
{{- end }}
