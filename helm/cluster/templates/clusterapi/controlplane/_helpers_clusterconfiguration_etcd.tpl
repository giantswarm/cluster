{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.etcd" }}
local:
  {{- with $etcdConfig := $.Values.internal.advancedConfiguration.controlPlane.etcd }}
  {{- if $etcdConfig.dataDir }}
  dataDir: {{ $etcdConfig.dataDir | quote }}
  {{- end }}
  {{- if $etcdConfig.imageTag }}
  imageTag: {{ $etcdConfig.imageTag | quote }}
  {{- else if $.Values.providerIntegration.useReleases }}
  {{- $_ := set $ "componentName" "etcd" }}
  {{- $version := include "cluster.component.version" $ }}
  {{- if ne $version "N/A" }}
  imageTag: {{ printf "v%s" $version | quote }}
  {{- end }}
  {{- end }}
  {{- /*
    All extraArgs must be strings, as the extraArg object is a map[string]string so numbers
    and booleans must be quoted here.
  */}}
  extraArgs:
  - name: listen-metrics-urls
    value: "http://0.0.0.0:2381"
  - name: quota-backend-bytes
    value: {{ mul $etcdConfig.quotaBackendBytesGiB 1024 1024 1024 | quote }}
  {{- if $etcdConfig.initialCluster }}
  - name: initial-cluster
    value: {{ $etcdConfig.initialCluster | quote }}
  {{- end }}
  {{- if $etcdConfig.initialClusterState }}
  - name: initial-cluster-state
    value: {{ $etcdConfig.initialClusterState | quote }}
  {{- end }}
  {{- range $argName, $argValue := $etcdConfig.extraArgs }}
  - name: {{ $argName }}
    value: {{ $argValue | quote }}
  {{- end }}
  {{- if $etcdConfig.experimental.peerSkipClientSanVerification }}
  - name: experimental-peer-skip-client-san-verification
    value: {{ $etcdConfig.experimental.peerSkipClientSanVerification | quote }}
  {{- end }}
  {{- end }}
{{- end }}
