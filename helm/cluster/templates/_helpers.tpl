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
{{- define "cluster.labels.common.all" -}}
{{ include "cluster.labels.common" $ -}}
{{ include "cluster.labels.custom" $ -}}
{{- end -}}

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
{{- if $.Values.providerIntegration.useReleases }}
release.giantswarm.io/version: {{ .Values.global.release.version | trimPrefix "v" | quote }}
{{- end }}
{{- end -}}

{{- define "cluster.labels.preventDeletion" }}
{{- if $.Values.global.metadata.preventDeletion }}
giantswarm.io/prevent-deletion: "true"
{{- end }}
{{- end }}

{{- define "cluster.labels.custom" -}}
{{- if .Values.global.metadata.labels }}
{{- range $key, $val := .Values.global.metadata.labels }}
{{ $key }}: {{ $val | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

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

{{/* Function to get the container registry mirror configuration based on location */}}
{{- define "cluster.container.mirrors" -}}
{{- if $.Values.providerIntegration.registry.mirrorsTemplateName -}}
  {{- include $.Values.providerIntegration.registry.mirrorsTemplateName $ -}}
{{- else -}}
  {{- $.Values.global.components.containerd.containerRegistries | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
  cluster.internal.get-provider-integration-values named helper template gets provider-integration Helm values and sets
  them in the $.GiantSwarm.providerIntegration object.

  For more details about how this works and how and why it is used, see explanation for the named helper template
  cluster.internal.get-internal-values, since this template serves the same purpose and works in the same way, just for
  $.Values.providerIntegration (vs $.Values.cluster.providerIntegration) Helm values.
*/}}
{{- define "cluster.internal.get-provider-integration-values" }}
{{- $providerIntegration := dict }}
{{- /* Case 1: template is called from the cluster chart itself */}}
{{- if and $.Chart (eq $.Chart.Name "cluster") $.Values.providerIntegration }}
  {{- $providerIntegration = $.Values.providerIntegration }}
{{- /* Case 2: template is called from a parent chart that passes Helm values to cluster chart in .Values.cluster */}}
{{- else if ($.Values.cluster).providerIntegration }}
  {{- $providerIntegration = $.Values.cluster.providerIntegration }}
{{- /* Case 3: template is called from tpl context where Chart is not available, use direct access */}}
{{- else if $.Values.providerIntegration }}
  {{- $providerIntegration = $.Values.providerIntegration }}
{{- end }}
{{- /* Create $.GiantSwarm object where we put custom Giant Swarm vars */}}
{{- if not $.GiantSwarm }}
  {{- $_ := set $ "GiantSwarm" dict }}
{{- end }}
{{- /* Finally set $.GiantSwarm.providerIntegration object that can be used in other templates */}}
{{- $_ := set $.GiantSwarm "providerIntegration" $providerIntegration }}
{{- end }}

{{/*
  cluster.internal.get-internal-values named helper template gets internal Helm values and sets them in the
  $.GiantSwarm.internal object.

  Some public named helper templates from cluster chart are using cluster chart's $.Values.internal Helm values, or to
  be more precise, Helm values under 'internal' key that you can see here in the cluster chart repo in values.yaml file.
  While all this sounds fine at the first sight, there is a caveat:
  - This works without issues when these named helper templates are called from other templates that are rendered in the
    cluster chart (e.g. templates for Cluster API resources). In this case Helm values root context is what you see in
    cluster chart values.yaml.
  - However, when these public named helper templates are called from a parent chart (e.g. cluster-aws, cluster-vsphere,
    etc), then Helm values root context is different, because we get the root context of the parent chart, and then
    cluster chart's internal Helm values are set in $.Values.cluster.internal Helm value (and not in $.Values.internal).

  This template here checks who is making the call to the template and then reads internal Helm values from the correct
  place and sets those values in $.GiantSwarm.internal object. This way other templates that need internal values can
  just call this first and then use $.GiantSwarm.internal object, e.g.:

    {{- $_ := include "cluster.internal.get-internal-values" $ }}
    foo: {{ $.GiantSwarm.internal.bar }}
*/}}
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
{{- /* Finally set ".GiantSwarm.internal" property that can be used in other templates */}}
{{- $_ := set $.GiantSwarm "internal" $internalValues }}
{{- end }}

{{/*
  cluster.internal.get-release-resource helper gets Release resources from the management cluster
  and it sets it in $.GiantSwarm.Release object.

  The helper will try to get a Release CR named <provider name>-<release version without 'v'>.

  Release version is obtained from Helm value $.Values.global.release.version (Helm value can have
  'v' prefix which is then stripped). Example values for $.Values.global.release.version:
  - 25.1.0
  - v25.1.0
  - 26.4.0-alpha.1
  - 27.2.0-e2e.h92f8d3456

  Provider name is obtained from Helm value $.Values.providerIntegration.provider. Provider names
  of the current providers (as of June 2024) are:
  - aws
  - azure
  - vshpere
  - cloud-director

  If the Release resource is not found, then the behavior depends on the value of
  $.GiantSwarm.internal.ephemeralConfiguration.offlineTesting.renderWithoutReleaseResource:
  - if renderWithoutReleaseResource is false, template rendering fails,
  - if renderWithoutReleaseResource is true, template does nothing.
 */}}
{{- define "cluster.internal.get-release-resource" }}
{{- $_ := include "cluster.internal.get-internal-values" $ }}
{{- $_ = include "cluster.internal.get-provider-integration-values" $ }}
{{- $renderWithoutReleaseResource := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- $releaseVersion := $.Values.global.release.version | trimPrefix "v" }}
{{- $releaseVersion = printf "%s-%s" $.GiantSwarm.providerIntegration.provider $releaseVersion }}
{{- $release := lookup "release.giantswarm.io/v1alpha1" "Release" "" $releaseVersion }}
{{- if $release }}
  {{- $_ := set $.GiantSwarm "Release" $release }}
{{ else if not $renderWithoutReleaseResource }}
  {{- fail (printf "Release resource '%s' not found" $releaseVersion) }}
{{- end }}
{{- end }}

{{/*
  cluster.app.version is a public named helper template that returns a version of the app that is specified under
  property 'appName' in the object that is passed to the template. App version is obtained from the Release resource.

  Example usage in template:

    {{- $_ := set $ "appName" "foo-bar-controller" }}
    {{- $appVersion := include "cluster.app.version" $ }}
    version: {{ $appVersion }}
*/}}
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

{{/*
  cluster.app.catalog is a public named helper template that returns a catalog of the app that is specified under
  property 'appName' in the object that is passed to the template. App catalog is obtained from the Release resource.

  Example usage in template:

    {{- $_ := set $ "appName" "foo-bar-controller" }}
    {{- $appCatalog := include "cluster.app.catalog" $ }}
    catalog: {{ $appCatalog }}
*/}}
{{- define "cluster.app.catalog" }}
{{- $appCatalog := "" }}
{{- $_ := (include "cluster.internal.get-release-resource" $) }}
{{- if $.GiantSwarm.Release }}
{{- range $_, $app := $.GiantSwarm.Release.spec.apps }}
{{- if eq $app.name $.appName }}
{{- $appCatalog = $app.catalog }}
{{- end }}
{{- end }}
{{- end }}
{{- $renderWithoutReleaseResource := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- if $appCatalog }}
{{- $appCatalog }}
{{- else if $renderWithoutReleaseResource -}}
{{- printf "fake-app-catalog-from-offline-cluster-chart-rendering" }}
{{- else }}
{{- fail (printf "Application not found in Release/%s: %s" (($.GiantSwarm.Release).metadata).name $.appName) }}
{{- end }}
{{- end }}

{{/*
  cluster.app.in-release is a public named helper template that checks if the app that is specified under
  property 'appName' in the object that is passed to the template exists in the Release.

  Example usage in template:

    {{- $_ := set $ "appName" "foo-bar-controller" }}
    {{- $appInRelease := include "cluster.app.in-release" $ }}
    {{- if $appInRelease }}
    {{!-- Do logic here... --}}
    {{- end }}
*/}}
{{- define "cluster.app.in-release" }}
{{- $inRelease := false }}
{{- $renderWithoutReleaseResource := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- if $renderWithoutReleaseResource }}
{{- $inRelease = true }}
{{- else }}
{{- $_ := (include "cluster.internal.get-release-resource" $) }}
{{- if $.GiantSwarm.Release }}
{{- range $_, $app := $.GiantSwarm.Release.spec.apps }}
{{- if eq $app.name $.appName }}
{{- $inRelease = true }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $inRelease }}
{{- end }}

{{/*
  cluster.app.dependencies is a public named helper template that renders a YAML array with app's dependencies for the
  app that is specified under property 'appName' in the object that is passed to the template. App dependencies are
  obtained from the Release resource.

  Example usage in template:

    {{- $_ := set $ "appName" "foo-exporter" }}
    {{- $dependenciesFromRelease := include "cluster.app.dependencies" $ | fromYamlArray }}
    {{- range $_, $dependency := $dependenciesFromRelease }}
      {{- $dependencies = append $dependencies $dependency }}
    {{- end }}
*/}}
{{- define "cluster.app.dependencies" }}
{{- $dependencies := list }}
{{- $_ := (include "cluster.internal.get-release-resource" $) }}
{{- if $.GiantSwarm.Release }}
  {{- range $_, $app := $.GiantSwarm.Release.spec.apps }}
    {{- if eq $app.name $.appName }}
      {{- range $_, $dependency := $app.dependsOn }}
      {{- $dependencies = append $dependencies $dependency }}
      {{- end}}
    {{- end }}
  {{- end }}
{{- end }}
{{- $dependencies | toYaml }}
{{- end }}

{{/*
  cluster.component.version is a public named helper template that returns a version of the component that is specified
  under property 'componentName' in the object that is passed to the template. Component version is obtained from the
  Release resource.

  Example usage in template:

    {{- $_ := set $ "componentName" "flatcar" }}
    {{- $componentVersion := include "cluster.component.version" $ }}
    version: {{ $componentVersion }}
*/}}
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

{{/*
  cluster.component.kubernetes.version is a public named helper template that returns the Kubernetes version. If the
  provider is using new Releases then the Kubernetes version is obtained from the Release resources, otherwise it is
  obtained from Helm values.

  Example usage in template:

    version: {{ include "cluster.component.kubernetes.version" $ }}
*/}}
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

{{/*
  DEPRECATED, use cluster.os.version instead.

  cluster.component.flatcar.version is a public named helper template that returns the Flatcar version. If the
  provider is using new Releases then the Flatcar version is obtained from the Release resources, otherwise it is
  obtained from Helm values.

  Example usage in template:

    version: {{ include "cluster.component.flatcar.version" $ }}
*/}}
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

{{/*
  DEPRECATED, use cluster.os.tooling.version instead.

  cluster.component.flatcar.variant is a public named helper template that returns the Flatcar image variant. If the
  provider is using new Releases then the Flatcar image variant is obtained from the Release resources, otherwise it is
  obtained from Helm values.

  Example usage in template:

    version: {{ include "cluster.component.flatcar.variant" $ }}
*/}}
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

{{/*
  cluster.os.name is a public named template that returns the operating system name.

  It returns a fixed value "flatcar".

  cluster-\<provider\> charts should use this template when building the operating system image name.
*/}}
{{- define "cluster.os.name" }}
{{- print "flatcar" }}
{{- end }}

{{/*
  cluster.os.releaseChannel is a public named template that returns the operating system release channel.

  It returns "stable" for all providers by default.

  In case some provider temporarily needs to use a different OS release channel, the value can be overridden in the
  cluster-<provider> chart with cluster chart Helm value .Values.providerIntegration.osImage.channel. A change like this
  requires a new cluster-<provider> chart version and then a new workload cluster release version.

  cluster-\<provider\> charts should use this template when building the operating system image name.
*/}}
{{- define "cluster.os.releaseChannel" }}
{{- $_ := include "cluster.internal.get-provider-integration-values" $ }}
{{- $.GiantSwarm.providerIntegration.osImage.channel | default "stable" }}
{{- end }}

{{/*
  cluster.os.version is a public named template that returns the operating system version.

  If the provider is using the new releases with the Release resource, then the operating system version is obtained
  from the Release resource, otherwise it is obtained from the provider integration Helm value.

  Example usage in template:

    version: {{ include "cluster.os.version" $ }}

  cluster-\<provider\> charts should use this template when building the operating system image name.
*/}}
{{- define "cluster.os.version" }}
{{- include "cluster.component.flatcar.version" $ }}
{{- end }}

{{/*
  cluster.os.tooling.version is a public named template that returns the OS tooling version.

  If the provider is using the new releases with the Release resource, then the OS tooling version is obtained from the
  Release resource, otherwise it is obtained from the provider integration Helm value
  .Values.providerIntegration.osImage.toolingVersion.

  cluster-\<provider\> charts should use this template when building the operating system image name.
*/}}
{{- define "cluster.os.tooling.version" }}
{{- $_ := include "cluster.internal.get-provider-integration-values" $ }}
{{- $_ = include "cluster.internal.get-internal-values" $ }}
{{- $renderWithoutReleaseResource := ((($.GiantSwarm.internal).ephemeralConfiguration).offlineTesting).renderWithoutReleaseResource | default false }}
{{- if $.GiantSwarm.providerIntegration.useReleases }}
    {{- $_ := set $ "componentName" "os-tooling" }}
    {{- $osToolingVersion := include "cluster.component.version" $ | trimPrefix "v" }}
    {{- $osToolingVersion }}
{{- else if $.GiantSwarm.providerIntegration.osImage }}
    {{- $.GiantSwarm.providerIntegration.osImage.toolingVersion }}
{{- else if not $renderWithoutReleaseResource }}
    {{- fail "Cannot determine OS tooling version" }}
{{- end }}
{{- end }}

{{/*
  cluster.containerd.selinux.enabled is a public named template that returns whether SELinux is enabled for containerd.

  There are two values that can be used to control this behavior:
  - .Values.global.components.containerd.selinux.enabled: this can be used to enable SELinux for containerd independently of the SELinux mode.
  - .Values.global.components.selinux.mode: this can be used to enforce SELinux on the nodes, which will also enable SELinux for containerd.
*/}}
{{- define "cluster.containerd.selinux.enabled" }}
{{- if or $.Values.global.components.containerd.selinux.enabled (eq $.Values.global.components.selinux.mode "enforcing") -}}
true
{{- else -}}
false
{{- end }}
{{- end }}
