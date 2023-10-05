{{- define "cluster.internal.kubeadm.preKubeadmCommands" }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.flatcar" . }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.ssh" . }}
{{- include "cluster.internal.kubeadm.preKubeadmCommands.proxy" . }}
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.flatcar" }}
- envsubst < /etc/kubeadm.yml > /etc/kubeadm.yml.tmp
- mv /etc/kubeadm.yml.tmp /etc/kubeadm.yml
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.ssh" }}
- systemctl restart sshd
{{- end }}

{{- define "cluster.internal.kubeadm.preKubeadmCommands.proxy" }}
{{- if and $.Values.global.connectivity.proxy $.Values.global.connectivity.proxy.enabled }}
- export HTTP_PROXY={{ $.Values.global.connectivity.proxy.httpProxy }}
- export HTTPS_PROXY={{ $.Values.global.connectivity.proxy.httpsProxy }}
- export NO_PROXY="{{ include "cluster.internal.kubeadm.proxy.noProxyList" $ }}"
- export http_proxy={{ $.Values.global.connectivity.proxy.httpProxy }}
- export https_proxy={{ $.Values.global.connectivity.proxy.httpsProxy }}
- export no_proxy="{{ include "cluster.internal.kubeadm.proxy.noProxyList" $ }}"
{{- end }}
{{- end }}
