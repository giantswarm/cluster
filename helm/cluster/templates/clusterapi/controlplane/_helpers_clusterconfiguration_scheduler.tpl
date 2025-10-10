{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler" }}
extraArgs:
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  {{- if include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" $ }}
  feature-gates: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" $ }}
  {{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" }}
{{- $providerFeatureGates := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.scheduler.featureGates }}
{{- $internalFeatureGates := $.Values.internal.advancedConfiguration.controlPlane.scheduler.featureGates }}
{{- $featureGates := dict "providerFeatureGates" $providerFeatureGates "internalFeatureGates" $internalFeatureGates }}
{{- include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" $featureGates }}
{{- end }}
