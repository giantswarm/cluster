{{- define "cluster.internal.kubeadm.files" }}
{{- include "cluster.internal.kubeadm.files.sysctl" . }}
{{- include "cluster.internal.kubeadm.files.systemd" . }}
{{- include "cluster.internal.kubeadm.files.ssh" . }}
{{- include "cluster.internal.kubeadm.files.kubelet" . }}
{{- include "cluster.internal.kubeadm.files.kubernetes" . }}
{{- include "cluster.internal.kubeadm.files.proxy" . }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.sysctl" }}
- path: /etc/sysctl.d/hardening.conf
  permissions: "0644"
  encoding: base64
  content: {{ $.Files.Get "files/etc/sysctl.d/hardening.conf" | b64enc }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.systemd" }}
{{- if and $.Values.internal.kubeadmConfig $.Values.internal.kubeadmConfig.systemd }}
{{- if and $.Values.internal.kubeadmConfig $.Values.internal.kubeadmConfig.systemd.timesyncd }}
- path: /etc/systemd/timesyncd.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/timesyncd.conf") . | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.kubelet" }}
{{- if and $.Values.internal.kubeadmConfig $.Values.internal.kubeadmConfig.kubelet }}
- path: /opt/kubelet-config.sh
  permissions: "0700"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/opt/kubelet-config.sh") . | b64enc }}
{{- if $.Values.internal.kubeadmConfig.kubelet.gracefulNodeShutdown }}
- path: /etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf
  permissions: "0700"
  encoding: base64
  content: {{ $.Files.Get "files/etc/systemd/logind.conf.d/zzz-kubelet-graceful-shutdown.conf" | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.kubernetes" }}
- path: /etc/kubernetes/policies/audit-policy.yaml
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/kubernetes/policies/audit-policy.yaml" | b64enc }}
- path: /etc/kubernetes/encryption/config.yaml
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "cluster.resource.name" $ }}-encryption-provider-config
      key: encryption
{{- end }}

{{- define "cluster.internal.kubeadm.files.ssh" }}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config" | b64enc }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.proxy" }}
{{- if and $.Values.global.connectivity.proxy $.Values.global.connectivity.proxy.enabled }}
- path: /etc/systemd/system/containerd.service.d/http-proxy.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/http-proxy.conf") $ | b64enc }}
- path: /etc/systemd/system/kubelet.service.d/http-proxy.conf
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/systemd/http-proxy.conf") $ | b64enc }}
{{- end }}
{{- end }}

{{- define "cluster.internal.kubeadm.files.proxy.noProxyList" }}
{{- /* Static NO_PROXY values */}}
{{- $noProxyList := list
  "127.0.0.1"
  "localhost"
  "svc"
  "local"
-}}
{{- /* Add cluster domain */}}
{{- $noProxyList = append $noProxyList (printf "%s.%s" (include "cluster.resource.name" $) $.Values.connectivity.baseDomain) -}}
{{- /* Add services CIDR blocks */}}
{{- range $servicesCidrBlock := $.Values.connectivity.network.services.cidrBlocks }}
{{- $noProxyList = append $noProxyList $servicesCidrBlock -}}
{{- end }}
{{- /* Add pods CIDR blocks */}}
{{- range $podsCidrBlock := $.Values.connectivity.network.pods.cidrBlocks }}
{{- $noProxyList = append $noProxyList $podsCidrBlock -}}
{{- end }}
{{- /* Add custom NO_PROXY values */}}
{{- range $noProxyAddress := $.Values.global.connectivity.proxy.noProxy.addresses }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- /* Add custom NO_PROXY values from template */}}
{{- if $.Values.global.connectivity.proxy.noProxy.addressesTemplate }}
{{- range $noProxyAddress := include $.Values.global.connectivity.proxy.noProxy.addressesTemplate $ | fromYamlArray }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- end }}
{{- /* Output NO_PROXY as a comma-separeted list of addresses */}}
{{- join "," (compact $noProxyList) | trim }}
{{- end }}

{{- define "cluster.test.internal.kubeadm.files.proxy.anotherNoProxyList" }}
- some.noproxy.address.giantswarm.io
- another.noproxy.address.giantswarm.io
{{- end }}
