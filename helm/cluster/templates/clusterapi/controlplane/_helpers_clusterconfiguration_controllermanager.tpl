{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager" }}
extraArgs:
  allocate-node-cidrs: "true"
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  cloud-provider: external
  cluster-cidr: {{ $.Values.global.connectivity.network.pods.cidrBlocks | first }}
  feature-gates: CronJobTimeZone=true
  terminated-pod-gc-threshold: {{ $.Values.internal.advancedConfiguration.controlPlane.controllerManager.terminatedPodGCThreshold | quote }}
{{- end }}
