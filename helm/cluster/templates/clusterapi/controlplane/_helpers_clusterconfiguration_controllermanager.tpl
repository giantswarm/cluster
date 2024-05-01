{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager" }}
extraArgs:
  allocate-node-cidrs: "true"
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  cloud-provider: external
{{- if and $.Values.providerIntegration.controlPlane.apiServer $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
  cloud-config: {{ $.Values.providerIntegration.controlPlane.apiServer.cloudConfig | quote }}
  external-cloud-volume-plugin: {{ $.Values.providerIntegration.provider | quote }}
{{- end }}
  cluster-cidr: {{ $.Values.global.connectivity.network.pods.cidrBlocks | first }}
  feature-gates: CronJobTimeZone=true
  terminated-pod-gc-threshold: {{ $.Values.internal.advancedConfiguration.controlPlane.controllerManager.terminatedPodGCThreshold | quote }}
{{- if and $.Values.providerIntegration.controlPlane.apiServer $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
extraVolumes:
  - name: cloud-config
    hostPath:  {{ $.Values.providerIntegration.controlPlane.apiServer.cloudConfig | quote }}
    mountPath:  {{ $.Values.providerIntegration.controlPlane.apiServer.cloudConfig | quote }}
    readOnly: true
{{- end }}
{{- end }}
