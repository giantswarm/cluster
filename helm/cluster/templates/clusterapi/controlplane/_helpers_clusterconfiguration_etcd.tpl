{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.etcd" }}
local:
  extraArgs:
    listen-metrics-urls: "http://0.0.0.0:2381"
    quota-backend-bytes: "8589934592"
    {{- with $etcdConfig := (($.Values.internal.controlPlane.kubeadmConfig).clusterConfiguration).etcd }}
    {{- if $etcdConfig.initialCluster }}
    initial-cluster: {{ $etcdConfig.initialCluster | quote }}
    {{- end }}
    {{- if $etcdConfig.initialClusterState }}
    initial-cluster-state: {{ $etcdConfig.initialClusterState | quote }}
    {{- end }}
    {{- range $argName, $argValue := $etcdConfig.extraArgs }}
    {{ $argName }}: {{ if kindIs "string" $argValue }}{{ $argValue | quote }}{{ else }}{{ $argValue }}{{ end }}
    {{- end }}
    {{- if ($etcdConfig.experimental).peerSkipClientSanVerification }}
    experimental-peer-skip-client-san-verification: {{ $etcdConfig.experimental.peerSkipClientSanVerification }}
    {{- end }}
    {{- end }}
{{- end }}
