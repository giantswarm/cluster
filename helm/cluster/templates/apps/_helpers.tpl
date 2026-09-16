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
{{- define "cluster.internal.apps.coredns.controlPlane.enabled" -}}
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

{{/*
Tolerations for the Cilium components that have to be schedulable before the CNI,
the CCM/CPI and the provider CSI node agents are up. Without them, those
components (which all depend on Cilium) and Cilium itself deadlock.
See https://github.com/giantswarm/giantswarm/issues/34121

The emitted list is the union of:

  - Provider-independent taints that are part of the node bootstrap sequence on
    every provider, plus `karpenter.sh/unregistered`. The latter is applied by
    Karpenter itself as a NodePool startup taint, so it never shows up in the
    kubeadm config taints below and has to be listed here.
  - Every taint the provider integration puts on nodes, i.e. the union of
    `providerIntegration.kubeadmConfig.taints` (all nodes),
    `providerIntegration.workers.kubeadmConfig.taints` and
    `providerIntegration.controlPlane.kubeadmConfig.taints`.

Tolerating a taint that a given provider never sets is a no-op, so the union is
safe to emit unconditionally. Tolerations are keyed with `operator: Exists` and
no `effect`, which covers every effect the matching taint may carry.

The toleration for `agentNotReadyTaintKey` (`node.cilium.io/agent-not-ready`) is
added by the cilium chart itself and must not be repeated here.
*/}}
{{- define "cluster.internal.apps.cilium.tolerations" -}}
{{- $tolerations := list
      (dict "key" "node-role.kubernetes.io/control-plane" "operator" "Exists")
      (dict "key" "node.kubernetes.io/not-ready" "operator" "Exists")
      (dict "key" "node.cloudprovider.kubernetes.io/uninitialized" "operator" "Exists")
      (dict "key" "node.cluster.x-k8s.io/uninitialized" "operator" "Exists")
      (dict "key" "karpenter.sh/unregistered" "operator" "Exists") -}}
{{- $seenKeys := dict -}}
{{- range $toleration := $tolerations -}}
{{- $_ := set $seenKeys $toleration.key true -}}
{{- end -}}
{{- $providerTaints := concat
      ($.Values.providerIntegration.kubeadmConfig.taints | default list)
      ($.Values.providerIntegration.workers.kubeadmConfig.taints | default list)
      ($.Values.providerIntegration.controlPlane.kubeadmConfig.taints | default list) -}}
{{- range $taint := $providerTaints -}}
{{- if not (hasKey $seenKeys $taint.key) -}}
{{- $_ := set $seenKeys $taint.key true -}}
{{- $tolerations = append $tolerations (dict "key" $taint.key "operator" "Exists") -}}
{{- end -}}
{{- end -}}
{{- toYaml $tolerations -}}
{{- end -}}
