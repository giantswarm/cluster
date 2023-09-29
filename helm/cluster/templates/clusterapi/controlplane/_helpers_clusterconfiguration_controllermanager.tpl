{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager" }}
extraArgs:
  allocate-node-cidrs: "true"
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  bind-address: 0.0.0.0
  cloud-provider: external
  cluster-cidr: {{ $.Values.connectivity.network.pods.cidrBlocks | first }}
  feature-gates: CronJobTimeZone=true
  terminated-pod-gc-threshold: "125"
{{- end }}
