{{/*
  "cluster.connectivity.proxy.noProxy" template renders the NO_PROXY value as a comma-separated string.

  Template argument is a dictionary with the following keys:
  - "global": mapped to $.Values.global,
  - "providerIntegration": mapped to provider-integration object.

  Example usage when inlcuded in the cluster chart:
    {{ include "cluster.connectivity.proxy.noProxy" (dict "global" $.Values.global "providerIntegration" $.Values.providerIntegration) }}

  Example usage when inlcuded in the parent chart (cluster-<provider> app):
    {{ include "cluster.connectivity.proxy.noProxy" (dict "global" $.Values.global "providerIntegration" $.Values.cluster.providerIntegration) }}

  You can notice in the above two examples that "providerIntegration" dict key is set to different Helm values, depending
  on from which chart it has been called. That is because the cluster chart value $.Values.providerIntegration is set as
  $.Values.cluster.providerIntegration in the parent chart (cluster-<provider> app).

  The rendered NO_PROXY value includes the following hosts, IP addresses and ranges:
  1. Static values "127.0.0.1", "localhost", "svc" and "local",
  2. Cluster domain in format "<cluster name>.<base domain>",
  3. Kubernetes services CIDR range, e.g. "172.31.0.0/16",
  4. Kubernetes pods CIDR range, e.g. "100.64.0.0/12",
  5. Provider-specific noProxy values specified in $.Values.providerIntegration.connectivity.proxy.noProxy, and
  6. Customer-provider cluster-specific noProxy values specified in $.Values.global.connectivity.proxy.noProxy.
*/}}
{{- define "cluster.connectivity.proxy.noProxy" }}
{{- $global := .global }}
{{- $metadata := $global.metadata }}
{{- $connectivity := $global.connectivity }}=
{{- $providerIntegration := .providerIntegration }}
{{- /* Static NO_PROXY values */}}
{{- $noProxyList := list
  "127.0.0.1"
  "localhost"
  "svc"
  "local"
-}}
{{- /* Add cluster domain */}}
{{- $noProxyList = append $noProxyList (printf "%s.%s" $metadata.name $connectivity.baseDomain) -}}
{{- /* Add services CIDR blocks */}}
{{- range $servicesCidrBlock := $connectivity.network.services.cidrBlocks }}
{{- $noProxyList = append $noProxyList $servicesCidrBlock -}}
{{- end }}
{{- /* Add pods CIDR blocks */}}
{{- range $podsCidrBlock := $connectivity.network.pods.cidrBlocks }}
{{- $noProxyList = append $noProxyList $podsCidrBlock -}}
{{- end }}
{{- /* Add provider-specific NO_PROXY values */}}
{{- range $noProxyAddress := $providerIntegration.connectivity.proxy.noProxy.value }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- /* Add provider-specific NO_PROXY values from template */}}
{{- if $providerIntegration.connectivity.proxy.noProxy.templateName }}
{{- range $noProxyAddress := include $providerIntegration.connectivity.proxy.noProxy.templateName $ | fromYamlArray }}
{{- $noProxyList = append $noProxyList $noProxyAddress -}}
{{- end }}
{{- end }}
{{- /* Add custom NO_PROXY values */}}
{{- if $connectivity.proxy.noProxy }}
{{- $customNoProxy := split "," $connectivity.proxy.noProxy }}
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
