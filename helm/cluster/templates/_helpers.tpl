{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a name stem for resource names
When resources are created from templates by Cluster API controllers, they are given random suffixes.
Given that Kubernetes allows 63 characters for resource names, the stem is truncated to 47 characters to leave
room for such suffix.
*/}}
{{- define "resource.default.name" -}}
{{- .Values.metadata.name | default (.Release.Name | replace "." "-" | trunc 47 | trimSuffix "-") -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "labels.common" -}}
{{- include "labels.selector" $ }}
helm.sh/chart: {{ include "chart" . | quote }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "labels.selector" -}}
app: {{ include "name" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
cluster.x-k8s.io/cluster-name: {{ include "resource.default.name" . | quote }}
giantswarm.io/cluster: {{ include "resource.default.name" . | quote }}
giantswarm.io/organization: {{ required "You must provide an existing organization name in .metadata.organization" .Values.metadata.organization | quote }}
cluster.x-k8s.io/watch-filter: capi
{{- end -}}
