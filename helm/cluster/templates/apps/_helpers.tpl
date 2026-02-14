{{/*
    clusterDNS IP is defined as 10th IP of the service CIDR in kubeadm. See:
    https://github.com/kubernetes/kubernetes/blob/d89d5ab2680bc74fe4487ad71e514f4e0812d9ce/cmd/kubeadm/app/constants/constants.go#L644-L645
    Such advanced logic can't be used in helm chart. Instead there is an
    assertion that the network is bigger than /24 and the last octet simply
    replaced with .10.
*/}}
{{- define "cluster.internal.apps.coredns.dns" -}}
    {{- $serviceCidrBlock := .Values.global.connectivity.network.services.cidrBlocks | first -}}
    {{- $mask := int (mustRegexReplaceAll `^.*/(\d+)$` $serviceCidrBlock "${1}") -}}
    {{- if gt $mask 24 -}}
        {{- fail (printf ".Values.global.connectivity.network.services.cidrBlocks=%q mask must be <= 24" $serviceCidrBlock) -}}
    {{- end -}}
    {{- mustRegexReplaceAll `^(\d+\.\d+\.\d+).*$` $serviceCidrBlock "${1}.10" -}}
{{- end -}}

{{/*
There are cases where we don't want to deploy the coreDns control plane components (for example when using Kamaji.)
*/}}
{{- define "cluster.internal.apps.coredns.mastersInstance.enabled" -}}
    {{- if not (include "kamaji.isEnabled" $) -}}
        {{- printf "true" -}}
    {{- else -}}
        {{- printf "false" -}}
    {{- end -}}
{{- end -}}

{{/*
Resolve App CR inconcistencies when baseDomain is taken from the catalog or from cluster-values.
See https://github.com/giantswarm/giantswarm/issues/29733
*/}}
{{- define "cluster.internal.apps.baseDomain" -}}
{{- if hasPrefix .Values.global.metadata.name .Values.global.connectivity.baseDomain -}}
{{- printf "%s" .Values.global.connectivity.baseDomain -}}
{{- else -}}
{{- printf "%s.%s" .Values.global.metadata.name .Values.global.connectivity.baseDomain -}}
{{- end -}}
{{- end -}}

{{/* Test helper used only in the CI */}}
{{- define "cluster.test.providerIntegration.apps.cilium.config" }}
hubble:
  relay:
    tolerations:
      - key: "node.cluster.x-k8s.io/uninitialized"
        operator: "Exists"
        effect: "NoSchedule"
  ui:
    tolerations:
      - key: "node.cluster.x-k8s.io/uninitialized"
        operator: "Exists"
        effect: "NoSchedule"
defaultPolicies:
  enabled: false
  remove: true

  tolerations:
    - effect: NoSchedule
      operator: Exists
    - effect: NoExecute
      operator: Exists
    - key: CriticalAddonsOnly
      operator: Exists
extraPolicies:
  allowEgressToCoreDNS:
    enabled: true
  allowEgressToProxy:
    enabled: {{ $.Values.global.connectivity.proxy.enabled }}
    httpProxy: {{ $.Values.global.connectivity.proxy.httpProxy | quote }}
    httpsProxy: {{ $.Values.global.connectivity.proxy.httpsProxy | quote }}
{{- end }}

{{/* Test helper used only in the CI */}}
{{- define "cluster.test.providerIntegration.apps.externalDns.config" }}
provider: aws
aws:
  irsa: "true"
  batchChangeInterval: null
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "{{ .Values.global.metadata.name }}-Route53Manager-Role"
extraArgs:
  - "--aws-batch-change-interval=10s"
ciliumNetworkPolicy:
  enabled: true
{{- end }}

{{/* Test helper used only in the CI */}}
{{- define "cluster.test.providerIntegration.apps.certExporter.config" }}
foo: bar
{{- end }}
