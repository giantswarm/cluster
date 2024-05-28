{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "cluster.chart.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cluster.chart.nameAndVersion" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a name stem for resource names
When resources are created from templates by Cluster API controllers, they are given random suffixes.
Given that Kubernetes allows 63 characters for resource names, the stem is truncated to 47 characters to leave
room for such suffix.
*/}}
{{- define "cluster.resource.name" -}}
{{- .Values.global.metadata.name | default (.Release.Name | replace "." "-" | trunc 47 | trimSuffix "-") -}}
{{- end -}}

{{/*
  Render all labels that are common for all resources.

  Included labels:
  - Common pre-defined labels from "cluster.labels.common" template,
  - Custom labels specified in .Values.global.metadata.labels.
*/}}
{{- define "cluster.labels.common.all" }}
{{ include "cluster.labels.common" $ }}
{{- $labels := dict }}
{{- if .Values.global.metadata.labels }}
{{- $labels = .Values.global.metadata.labels }}
{{- end }}
{{- range $key, $val := $labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cluster.labels.common" -}}
# deprecated: "app: cluster-{{ .Values.providerIntegration.provider }}" label is deprecated and it will be removed after upgrading
# to Kubernetes 1.25. We still need it here because existing ClusterResourceSet selectors
# need this label on the Cluster resource.
app: "cluster-{{ .Values.providerIntegration.provider }}"
app.kubernetes.io/name: {{ include "cluster.chart.name" $ | quote }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/part-of: "cluster-{{ .Values.providerIntegration.provider }}"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
helm.sh/chart: {{ include "cluster.chart.nameAndVersion" $ | quote }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
giantswarm.io/cluster: {{ include "cluster.resource.name" . | quote }}
giantswarm.io/organization: {{ required "You must provide an existing organization name in .global.metadata.organization" .Values.global.metadata.organization | quote }}
giantswarm.io/service-priority: {{ .Values.global.metadata.servicePriority }}
cluster.x-k8s.io/cluster-name: {{ include "cluster.resource.name" $ | quote }}
cluster.x-k8s.io/watch-filter: capi
{{- end -}}

{{- define "cluster.labels.preventDeletion" }}
{{- if $.Values.global.metadata.preventDeletion }}
giantswarm.io/prevent-deletion: "true"
{{- end }}
{{- end }}

{{- define "cluster.labels.custom" }}
{{- if .Values.global.metadata.labels }}
{{- range $key, $val := .Values.global.metadata.labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
  Render all annotations that are common for all resources.

  Included annotations:
  - Custom annotations specified in .Values.global.metadata.annotations,
  - cluster.giantswarm.io/description, if .Values.global.metadata.description is specified.
*/}}
{{- define "cluster.annotations.common.all" }}
{{- $annotations := dict }}
{{- if .Values.global.metadata.annotations }}
{{- $annotations = .Values.global.metadata.annotations }}
{{- end }}
{{- if $.Values.global.metadata.description }}
{{- $_ := set $annotations "cluster.giantswarm.io/description" $.Values.global.metadata.description }}
{{- end }}
{{- range $key, $val := $annotations }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}

{{- define "cluster.annotations.custom" }}
{{- if .Values.global.metadata.annotations }}
{{- range $key, $val := .Values.global.metadata.annotations }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Hash function based on data provided
Expects two arguments (as a `dict`) E.g.
  {{ include "hash" (dict "data" . "salt" .Values.providerIntegration.hasSalt) }}
Where `data` is the data to hash and `global` is the top level scope.
*/}}
{{- define "cluster.data.hash" -}}
{{- $data := mustToJson .data | toString  }}
{{- $salt := "" }}
{{- if .salt }}{{ $salt = .salt}}{{end}}
{{- (printf "%s%s" $data $salt) | quote | sha1sum | trunc 8 }}
{{- end -}}

{{/* Function that gets a Helm value based on its path */}}
{{- define "cluster.values.get" -}}
{{- $propertyPath := .path }}
{{- $pathParts := split "." $propertyPath }}
{{- $propertyValue := .Values }}
{{- range $pathPart := $pathParts }}
{{- $propertyValue = get $propertyValue $pathPart }}
{{- end }}
{{ $propertyValue }}
{{- end }}

{{/* Function that checks if a Helm value from a path is equal to a specified value */}}
{{- define "cluster.values.equal" -}}
{{- $propertyPath := .path }}
{{- $pathParts := split "." $propertyPath }}
{{- $propertyValue := .Values }}
{{- range $pathPart := $pathParts }}
{{- $propertyValue = get $propertyValue $pathPart }}
{{- end }}
{{- $testValue := .testValue }}
{{ eq $propertyValue $testValue }}
{{- end }}

{{/* Function to determine the value of container image registry that is used across whole repository */}}
{{- define "cluster.image.registry" -}}
{{- $registry := $.Values.internal.advancedConfiguration.registry -}}
{{- if $.Values.providerIntegration.registry -}}
{{- if $.Values.providerIntegration.registry.templateName -}}
{{- $registry = ( include $.Values.providerIntegration.registry.templateName $ ) -}}
{{- end -}}
{{- end -}}
{{- $registry -}}
{{- end -}}

{{- define "cluster.internal.get-provider-integration-values" }}
{{- $providerIntegration := dict }}
{{- /* Case 1: template is called from the cluster chart itself */}}
{{- if and (eq $.Chart.Name "cluster") $.Values.providerIntegration }}
  {{- $providerIntegration = $.Values.providerIntegration }}
{{- /* Case 2: template is called from a parent chart that passes Helm values to cluster chart in .Values.cluster */}}
{{- else if ($.Values.cluster).providerIntegration }}
  {{- $providerIntegration = $.Values.cluster.providerIntegration }}
{{- end }}
{{- /* Create $.GiantSwarm object where we put custom Giant Swarm vars */}}
{{- if not $.GiantSwarm }}
  {{- $_ := set $ "GiantSwarm" dict }}
{{- end }}
{{- /* Finally set "UseReleases" property that can be used in other templates */}}
{{- $_ := set $.GiantSwarm "providerIntegration" $providerIntegration }}
{{- end }}

{{- define "cluster.internal.get-internal-values" }}
{{- $internalValues := dict }}
{{- /* Case 1: template is called from the cluster chart itself */}}
{{- if and (eq $.Chart.Name "cluster") $.Values.internal }}
  {{- $internalValues = $.Values.internal }}
{{- /* Case 2: template is called from a parent chart that passes Helm values to cluster chart in .Values.cluster */}}
{{- else if ($.Values.cluster).internal }}
  {{- $internalValues = $.Values.cluster.internal }}
{{- end }}
{{- /* Create $.GiantSwarm.internal object */}}
{{- if not $.GiantSwarm }}
  {{- $_ := set $ "GiantSwarm" dict }}
{{- end }}
{{- /* Finally set "UseReleases" property that can be used in other templates */}}
{{- $_ := set $.GiantSwarm "internal" $internalValues }}
{{- end }}

{{- define "cluster.internal.get-release-resource" }}
{{- $_ := include "cluster.internal.get-internal-values" $ }}
{{- $renderWithoutReleaseResource := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- $releaseVersion := $.Values.global.release.version | trimPrefix "v" }}
{{- $releaseVersion = printf "v%s" $releaseVersion }}
{{- $release := lookup "release.giantswarm.io/v1alpha1" "Release" "" $releaseVersion }}
{{- if $release }}
  {{- $_ := set $.GiantSwarm "Release" $release }}
{{ else if not $renderWithoutReleaseResource }}
  {{- fail (printf "Release resource '%s' not found" $releaseVersion) }}
{{- end }}
{{- end }}

{{- define "cluster.app.version" }}
{{- $appVersion := "N/A" }}
{{- $_ := (include "cluster.internal.get-release-resource" $) }}
{{- if $.GiantSwarm.Release }}
{{- range $_, $app := $.GiantSwarm.Release.spec.apps }}
{{- if eq $app.name $.appName }}
{{- $appVersion = $app.version }}
{{- end }}
{{- end }}
{{- end }}
{{- $appVersion }}
{{- end }}

{{- define "cluster.component.version" }}
{{- $componentVersion := "N/A" }}
{{- $_ := (include "cluster.internal.get-release-resource" $) }}
{{- if $.GiantSwarm.Release }}
{{- range $_, $component := $.GiantSwarm.Release.spec.components }}
{{- if eq $component.name $.componentName }}
{{- $componentVersion = $component.version }}
{{- end }}
{{- end }}
{{- end }}
{{- $componentVersion }}
{{- end }}

{{- define "cluster.component.kubernetes.version" }}
{{- $_ := include "cluster.internal.get-provider-integration-values" $ }}
{{- if $.GiantSwarm.providerIntegration.useReleases }}
{{- $_ := set $ "componentName" "kubernetes" }}
{{- include "cluster.component.version" $ | trimPrefix "v" }}
{{- else if $.GiantSwarm.providerIntegration.kubernetesVersion }}
{{- $.GiantSwarm.providerIntegration.kubernetesVersion | trimPrefix "v" }}
{{- else }}
{{- fail "Cannot determine Kubernetes version" }}
{{- end }}
{{- end }}

{{- define "cluster.component.flatcar.version" }}
{{- $_ := include "cluster.internal.get-provider-integration-values" $ }}
{{- if $.GiantSwarm.providerIntegration.useReleases }}
{{- $_ := set $ "componentName" "flatcar" }}
{{- $flatcarVersion := include "cluster.component.version" $ | trimPrefix "v" }}
{{- $flatcarVersion }}
{{- else if $.GiantSwarm.providerIntegration.osImage }}
{{- $.GiantSwarm.providerIntegration.osImage.version }}
{{- else }}
{{- fail "Cannot determine Flatcar version" }}
{{- end }}
{{- end }}

{{- define "cluster.component.flatcar.variant" }}
{{- $_ := include "cluster.internal.get-provider-integration-values" $ }}
{{- if $.GiantSwarm.providerIntegration.useReleases }}
{{- $_ := set $ "componentName" "flatcar-variant" }}
{{- $flatcarVariant := include "cluster.component.version" $ | trimPrefix "v" | split "." }}
{{- $flatcarVariant._0 }}
{{- else if $.GiantSwarm.providerIntegration.osImage }}
{{- $.GiantSwarm.providerIntegration.osImage.variant }}
{{- else }}
{{- fail "Cannot determine Flatcar image variant" }}
{{- end }}
{{- end }}
