{{- define "cluster.test.awsContainerImageRegistry" -}}
{{- if hasPrefix "cn-" $.Values.global.providerSpecific.region -}}
giantswarm-registry.cn-shanghai.cr.aliyuncs.com
{{- else -}}
gsoci.azurecr.io
{{- end }}
{{- end }}

{{- define "cluster.test.awsContainerMirrorRegistry" -}}
{{- if hasPrefix "cn-" $.Values.global.providerSpecific.region -}}
docker.io:
- endpoint: giantswarm-registry.cn-shanghai.cr.aliyuncs.com
- endpoint: gsoci.azurecr.io
gsoci.azurecr.io:
- endpoint: giantswarm-registry.cn-shanghai.cr.aliyuncs.com
- endpoint: gsoci.azurecr.io
{{- else -}}
{{- $.Values.global.components.containerd.containerRegistries | toYaml -}}
{{- end -}}
{{- end -}}
