{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.scheduler" }}
extraArgs:
  authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
  # Security hardening: Restrict bind address to localhost only (CIS 1.4.1)
  bind-address: 127.0.0.1
  # Security hardening: Disable profiling unless explicitly needed (CIS 1.4.2)  
  profiling: false
  # Security hardening: Enable authentication and authorization
  authentication-kubeconfig: /etc/kubernetes/scheduler.conf
  authorization-kubeconfig: /etc/kubernetes/scheduler.conf
{{- end }}
