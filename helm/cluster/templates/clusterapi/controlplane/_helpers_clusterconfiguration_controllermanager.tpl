{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager" }}
extraArgs:
  allocate-node-cidrs: "true"
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  cloud-provider: external
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
  cloud-config: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
{{- end }}
  cluster-cidr: {{ $.Values.global.connectivity.network.pods.cidrBlocks | first }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.externalCloudVolumePlugin  }}
  external-cloud-volume-plugin: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.externalCloudVolumePlugin  }}
{{- end }}
  {{- if include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates" $ }}
  feature-gates: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates" $ }}
  {{- end }}
  terminated-pod-gc-threshold: {{ $.Values.internal.advancedConfiguration.controlPlane.controllerManager.terminatedPodGCThreshold | quote }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
extraVolumes:
  - name: cloud-config
    hostPath:  {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
    mountPath:  {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
    readOnly: true
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates" }}
{{- $providerFeatureGates := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.featureGates }}
{{- $internalFeatureGates := $.Values.internal.advancedConfiguration.controlPlane.controllerManager.featureGates }}
{{- $featureGates := dict "providerFeatureGates" $providerFeatureGates "internalFeatureGates" $internalFeatureGates "root" $ }}
{{- include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" $featureGates }}
{{- end }}
