{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.etcd" }}
local:
  extraArgs:
    listen-metrics-urls: "http://0.0.0.0:2381"
    quota-backend-bytes: "8589934592"
{{- end }}
