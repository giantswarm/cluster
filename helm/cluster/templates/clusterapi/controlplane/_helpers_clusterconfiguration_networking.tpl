{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.networking" }}
serviceSubnet: {{ join "," .Values.connectivity.network.services.cidrBlocks | quote }}
{{- end }}
