{{- define "cluster.internal.test.controlPlane.machineTemplate.spec" -}}
template:
  metadata:
    cluster.x-k8s.io/role: controlPlane
    {{- include "cluster.labels.common" $ | nindent 4 }}
  spec:
    machineType: "superBig"
{{- end -}}

{{/*
  A helper function to merge and join feature gates from internal configuration and provider integration as a comma separated string.

  Expects a dictionary with the keys `providerFeatureGates`, `internalFeatureGates`, and `root`.
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" }}
{{- $providerFeatureGates := .providerFeatureGates | default list }}
{{- $internalFeatureGates := .internalFeatureGates | default list }}
{{- $allFeatureGates := concat $providerFeatureGates $internalFeatureGates }}
{{- $root := .root }}
{{- /* Get kubernetes version using the standard helper (now works in tpl context) */}}
{{- $kubernetesVersion := include "cluster.component.kubernetes.version" $root }}
{{- /* Use outputDict pattern to avoid YAML serialization issues */}}
{{- $outputDict := dict }}
{{- $_ := include "cluster.internal.filterFeatureGatesByVersion" (dict "featureGates" $allFeatureGates "currentVersion" $kubernetesVersion "outputDict" $outputDict) }}
{{- $filteredFeatureGates := $outputDict.result | default list }}
{{- $mergedFeatureGates := dict }}
{{- range $filteredFeatureGates }}
{{- $_ := set $mergedFeatureGates (trim .name) .enabled }}
{{- end }}
{{- $featureGates := list }}
{{- range $name, $enabled := $mergedFeatureGates }}
{{- $featureGates = append $featureGates (printf "%s=%t" $name $enabled) }}
{{- end }}
{{- $featureGates | join "," }}
{{- end }}
