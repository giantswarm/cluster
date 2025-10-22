{{- define "cluster.internal.machinehealthcheck.commonspec" -}}
maxUnhealthy: {{ .maxUnhealthy | default "40%" | quote }}
nodeStartupTimeout: {{ .nodeStartupTimeout | default "8m0s" | quote }}
unhealthyConditions:
  - type: Ready
    status: Unknown
    timeout: {{ .unhealthyUnknownTimeout | default "10m0s" | quote }}
  - type: Ready
    status: "False"
    timeout: {{ .unhealthyNotReadyTimeout | default "10m0s" | quote }}

  {{- /* Conditions of node-problem-detector-app */}}
  {{- if .diskFullContainerdTimeout }}
  - type: DiskFullContainerd
    status: "True"
    timeout: {{ .diskFullContainerdTimeout | quote }}
  {{- end }}
  {{- if .diskFullKubeletTimeout }}
  - type: DiskFullKubelet
    status: "True"
    timeout: {{ .diskFullKubeletTimeout | quote }}
  {{- end }}
  {{- if .diskFullVarLogTimeout }}
  - type: DiskFullVarLog
    status: "True"
    timeout: {{ .diskFullVarLogTimeout | quote }}
  {{- end }}
{{- end -}}

{{- define "cluster.internal.machinehealthcheck.uses-node-problem-detector" -}}
  {{- /* Check if the control plane or any node pool uses features of node-problem-detector-app and print "true" in that case, otherwise nothing (= falsy) */}}
  {{- if $.Values.providerIntegration.resourcesApi.machineHealthCheckResourceEnabled }}
    {{- $allMachineHealthCheckObjects := list }}

    {{- if $.Values.providerIntegration.resourcesApi.controlPlaneResourceEnabled }}
      {{- $allMachineHealthCheckObjects = append $allMachineHealthCheckObjects $.Values.global.controlPlane.machineHealthCheck }}
    {{- end }}

    {{- range $_, $nodePoolConfig := $.Values.global.nodePools | default $.Values.providerIntegration.workers.defaultNodePools }}
      {{- if $nodePoolConfig.machineHealthCheck }}
        {{- $allMachineHealthCheckObjects = append $allMachineHealthCheckObjects $nodePoolConfig.machineHealthCheck }}
      {{- end }}
    {{- end }}

    {{- range $machineHealthCheck := $allMachineHealthCheckObjects }}
      {{- if required "machineHealthCheck enabled property is required" $machineHealthCheck.enabled }}
        {{- if or $machineHealthCheck.diskFullContainerdTimeout $machineHealthCheck.diskFullKubeletTimeout $machineHealthCheck.diskFullVarLogTimeout }}
          {{- print "true" }}
          {{- break }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
