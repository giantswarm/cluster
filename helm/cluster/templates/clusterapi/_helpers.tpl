{{- define "cluster.internal.kubeadm.proxy.noProxyList" }}
{{- /* Static NO_PROXY values */}}
{{- $noProxyList := list
  "127.0.0.1"
  "localhost"
  "svc"
  "local"
-}}
{{- /* Add cluster domain */}}
{{- $noProxyList = append $noProxyList (printf "%s.%s" (include "cluster.resource.name" $) $.Values.global.connectivity.baseDomain) -}}
{{- /* Add services CIDR blocks */}}
{{- range $servicesCidrBlock := $.Values.global.connectivity.network.services.cidrBlocks }}
{{- $noProxyList = append $noProxyList $servicesCidrBlock -}}
{{- end }}
{{- /* Add pods CIDR blocks */}}
{{- range $podsCidrBlock := $.Values.global.connectivity.network.pods.cidrBlocks }}
{{- $noProxyList = append $noProxyList $podsCidrBlock -}}
{{- end }}
{{- /* Add provider-specific NO_PROXY values */}}
{{- range $noProxyAddress := $.Values.providerIntegration.connectivity.proxy.noProxy.value }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- /* Add provider-specific NO_PROXY values from template */}}
{{- if $.Values.providerIntegration.connectivity.proxy.noProxy.templateName }}
{{- range $noProxyAddress := include $.Values.providerIntegration.connectivity.proxy.noProxy.templateName $ | fromYamlArray }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- end }}
{{- /* Add custom NO_PROXY values */}}
{{- if $.Values.global.connectivity.proxy.noProxy }}
{{- $customNoProxy := split "," $.Values.global.connectivity.proxy.noProxy }}
{{- range $noProxyAddress := $customNoProxy }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- end }}
{{- /* Output NO_PROXY as a comma-separeted list of addresses */}}
{{- join "," (compact $noProxyList) | trim }}
{{- end }}

{{- define "cluster.test.internal.kubeadm.proxy.anotherNoProxyList" }}
- some.noproxy.address.giantswarm.io
- another.noproxy.address.giantswarm.io
{{- end }}

{{- define "cluster.test.providerIntegration.connectivity.annotations" }}
network-topology.giantswarm.io/mode: None
network-topology.giantswarm.io/transit-gateway: abc-123
network-topology.giantswarm.io/prefix-list: "foo,bar"
{{- end }}
