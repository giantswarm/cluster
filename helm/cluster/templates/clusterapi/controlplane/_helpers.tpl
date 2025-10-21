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

  Expects a dictionary with the keys:
    - providerFeatureGates: List of provider feature gates
    - internalFeatureGates: List of internal feature gates
    - kubernetesVersion: Current Kubernetes version to filter against

  Returns: Comma-separated string of feature gates (e.g., "Feature1=true,Feature2=false")
*/}}
{{- define "cluster.internal.controlPlane.kubeadm.clusterConfiguration.featureGates" }}
{{- $providerFeatureGates := .providerFeatureGates | default list }}
{{- $internalFeatureGates := .internalFeatureGates | default list }}
{{- $kubernetesVersion := .kubernetesVersion }}
{{- $allFeatureGates := concat $providerFeatureGates $internalFeatureGates }}
{{- /* Filter feature gates by version */}}
{{- $filteredFeatureGates := list }}
{{- range $allFeatureGates }}
{{- if not .minKubernetesVersion }}
{{- /* No version requirement, always include */}}
{{- $filteredFeatureGates = append $filteredFeatureGates . }}
{{- else if and $kubernetesVersion (semverCompare (printf ">=%s" .minKubernetesVersion) $kubernetesVersion) }}
{{- /* Version requirement met */}}
{{- $filteredFeatureGates = append $filteredFeatureGates . }}
{{- end }}
{{- end }}
{{- /* Merge feature gates (later entries override earlier ones) */}}
{{- $mergedFeatureGates := dict }}
{{- range $filteredFeatureGates }}
{{- $_ := set $mergedFeatureGates (trim .name) .enabled }}
{{- end }}
{{- /* Format as comma-separated key=value string */}}
{{- $featureGates := list }}
{{- range $name, $enabled := $mergedFeatureGates }}
{{- $featureGates = append $featureGates (printf "%s=%t" $name $enabled) }}
{{- end }}
{{- $featureGates | join "," }}
{{- end }}
