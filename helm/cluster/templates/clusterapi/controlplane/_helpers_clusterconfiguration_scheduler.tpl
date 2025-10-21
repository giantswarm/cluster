{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler" }}
extraArgs:
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  {{- if include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" $ }}
  feature-gates: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" $ }}
  {{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler.featureGates" }}
{{- $kubernetesVersion := include "cluster.component.kubernetes.version" $ }}
{{- $providerFeatureGates := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.scheduler.featureGates }}
{{- $internalFeatureGates := $.Values.internal.advancedConfiguration.controlPlane.scheduler.featureGates }}
{{- include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" (dict "providerFeatureGates" $providerFeatureGates "internalFeatureGates" $internalFeatureGates "kubernetesVersion" $kubernetesVersion) }}
{{- end }}
