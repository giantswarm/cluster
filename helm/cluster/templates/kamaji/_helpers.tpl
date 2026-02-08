{{/*
Creates a flag indicating whether Kamaji is being used as control plane provider.
*/}}
{{- define "isKamaji" -}}
    {{- if and
      $.Values.providerIntegration.resourcesApi.controlPlaneResource.enabled
      (eq $.Values.providerIntegration.resourcesApi.controlPlaneResource.provider "kamaji")
    }}
        {{- printf "true" -}}
    {{- end }}
{{- end }}

{{/*
Defines the name of the HelmRelease for the Kamaji Etcd chart.
*/}}
{{- define "kamajiEtcdHelmreleaseName" -}}
{{ include "cluster.resource.name" $ }}-kamaji-etcd
{{- end }}

{{/*
Defines common container configuration for Jobs.
*/}}

{{- define "securityContext.runAsUser" -}}
1000
{{- end -}}
{{- define "securityContext.runAsGroup" -}}
1000
{{- end -}}

{{- define "jobContainerCommon" -}}
image: "{{ .Values.internal.kubectlImage.registry }}/{{ .Values.internal.kubectlImage.name }}:{{ .Values.internal.kubectlImage.tag }}"
securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
resources:
  requests:
    memory: "64Mi"
    cpu: "10m"
  limits:
    memory: "256Mi"
    cpu: "100m"
{{- end }}