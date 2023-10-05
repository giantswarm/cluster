{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.networking" }}
serviceSubnet: {{ join "," $.Values.global.connectivity.network.services.cidrBlocks | quote }}
{{- end }}
