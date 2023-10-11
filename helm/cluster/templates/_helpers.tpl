{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "cluster.chart.name" -}}
{{- $.Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cluster.chart.nameAndVersion" -}}
{{- printf "%s-%s" $.Chart.Name $.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a name stem for resource names
When resources are created from templates by Cluster API controllers, they are given random suffixes.
Given that Kubernetes allows 63 characters for resource names, the stem is truncated to 47 characters to leave
room for such suffix.
*/}}
{{- define "cluster.resource.name" -}}
{{- $.Values.global.metadata.name | default ($.Release.Name | replace "." "-" | trunc 47 | trimSuffix "-") -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cluster.labels.common" -}}
app: {{ include "cluster.chart.name" . | quote }}
app.kubernetes.io/managed-by: {{ $.Release.Service | quote }}
app.kubernetes.io/version: {{ $.Chart.Version | quote }}
application.giantswarm.io/team: {{ index $.Chart.Annotations "application.giantswarm.io/team" | quote }}
giantswarm.io/cluster: {{ include "cluster.resource.name" . | quote }}
giantswarm.io/organization: {{ required "You must provide an existing organization name in .global.metadata.organization" $.Values.global.metadata.organization | quote }}
giantswarm.io/service-priority: {{ $.Values.global.metadata.servicePriority }}
cluster.x-k8s.io/cluster-name: {{ include "cluster.resource.name" . | quote }}
cluster.x-k8s.io/watch-filter: capi
helm.sh/chart: {{ include "cluster.chart.nameAndVersion" . | quote }}
{{- end -}}

{{- define "cluster.labels.custom" }}
{{- if $.Values.global.metadata.labels }}
{{- range $key, $val := $.Values.global.metadata.labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cluster.annotations.custom" }}
{{- if $.Values.global.metadata.annotations }}
{{- range $key, $val := $.Values.global.metadata.annotations }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}
