{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager" }}
extraArgs:
  allocate-node-cidrs: "true"
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  cloud-provider: external
{{ if $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
  cloud-config:  {{ $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
  external-cloud-volume-plugin: {{ $.Values.providerIntegration.provider }}
{{- end }}
  cluster-cidr: {{ $.Values.global.connectivity.network.pods.cidrBlocks | first }}
  feature-gates: CronJobTimeZone=true
  terminated-pod-gc-threshold: {{ $.Values.internal.advancedConfiguration.controlPlane.controllerManager.terminatedPodGCThreshold | quote }}
{{ if $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
extraVolumes:
  - name: cloud-config
    hostPath:  {{ $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
    mountPath:  {{ $.Values.providerIntegration.controlPlane.apiServer.cloudConfig }}
    readOnly: true
{{- end }}
{{- end }}
