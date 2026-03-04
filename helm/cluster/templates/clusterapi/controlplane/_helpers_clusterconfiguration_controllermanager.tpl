{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager" }}
extraArgs:
- name: allocate-node-cidrs
  value: "true"
- name: authorization-always-allow-paths
  value: "/healthz,/readyz,/livez,/metrics"
- name: bind-address
  value: 0.0.0.0
- name: cloud-provider
  value: external
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig }}
- name: cloud-config
  value: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig }}
{{- end }}
- name: cluster-cidr
  value: {{ $.Values.global.connectivity.network.pods.cidrBlocks | first }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.externalCloudVolumePlugin }}
- name: external-cloud-volume-plugin
  value: {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.externalCloudVolumePlugin }}
{{- end }}
{{- if include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates" $ }}
- name: feature-gates
  value: {{ include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates" $ }}
{{- end }}
- name: terminated-pod-gc-threshold
  value: {{ $.Values.internal.advancedConfiguration.controlPlane.controllerManager.terminatedPodGCThreshold | quote }}
{{- if $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
extraVolumes:
  - name: cloud-config
    hostPath:  {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
    mountPath:  {{ $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.cloudConfig  }}
    readOnly: true
{{- end }}
{{- end }}

{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates" }}
{{- $kubernetesVersion := include "cluster.component.kubernetes.version" $ }}
{{- $providerFeatureGates := $.Values.providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.featureGates }}
{{- $internalFeatureGates := $.Values.internal.advancedConfiguration.controlPlane.controllerManager.featureGates }}
{{- $_ := include "cluster.internal.get-internal-values" $ }}
{{- $renderWithoutRelease := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- include "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" (dict "providerFeatureGates" $providerFeatureGates "internalFeatureGates" $internalFeatureGates "kubernetesVersion" $kubernetesVersion "renderWithoutReleaseResource" $renderWithoutRelease) }}
{{- end }}
