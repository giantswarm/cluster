{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.etcd" }}
local:
  {{- with $etcdConfig := $.Values.internal.advancedConfiguration.controlPlane.etcd }}
  {{- if $etcdConfig.dataDir }}
  dataDir: {{ $etcdConfig.dataDir | quote }}
  {{- end }}
  extraArgs:
    {{- /*
      All extraArgs must be strings, as the extraArg object is a map[string]string so numbers
      and booleans must be quoted here.
    */}}
    listen-metrics-urls: "http://0.0.0.0:2381"
    quota-backend-bytes: {{ mul $etcdConfig.quotaBackendBytesGiB 1024 1024 1024 | quote }}
    {{- if $etcdConfig.initialCluster }}
    initial-cluster: {{ $etcdConfig.initialCluster | quote }}
    {{- end }}
    {{- if $etcdConfig.initialClusterState }}
    initial-cluster-state: {{ $etcdConfig.initialClusterState | quote }}
    {{- end }}
    {{- range $argName, $argValue := $etcdConfig.extraArgs }}
    {{ $argName }}: {{ $argValue | quote }}
    {{- end }}
    {{- if $etcdConfig.experimental.peerSkipClientSanVerification }}
    experimental-peer-skip-client-san-verification: {{ $etcdConfig.experimental.peerSkipClientSanVerification | quote }}
    {{- end }}
    {{- end }}
{{- end }}
