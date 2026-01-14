{{- define "cluster.internal.controlPlane.structuredAuthorization.config" -}}
apiVersion: apiserver.config.k8s.io/v1
kind: AuthorizationConfiguration
authorizers:
{{- if $.Values.global.controlPlane.authorization.structuredAuthorization.authorizers }}
{{- range $authorizer := $.Values.global.controlPlane.authorization.structuredAuthorization.authorizers }}
  - type: {{ $authorizer.type | quote }}
    name: {{ $authorizer.name | quote }}
{{- if eq $authorizer.type "Webhook" }}
{{- with $authorizer.webhook }}
    webhook:
      timeout: {{ .timeout | default "3s" | quote }}
      subjectAccessReviewVersion: {{ .subjectAccessReviewVersion | default "v1" | quote }}
      matchConditionSubjectAccessReviewVersion: {{ .matchConditionSubjectAccessReviewVersion | default "v1" | quote }}
      failurePolicy: {{ .failurePolicy | default "Deny" | quote }}
      connectionInfo:
        type: {{ .connectionInfo.type | quote }}
{{- if eq .connectionInfo.type "KubeConfigFile" }}
        kubeConfigFile: {{ .connectionInfo.kubeConfigFile | quote }}
{{- end }}
{{- if .matchConditions }}
      matchConditions:
{{- range $condition := .matchConditions }}
        - expression: {{ $condition.expression | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- else }}
{{- /* Default authorizers: Node and RBAC */}}
  - type: "Node"
    name: "node"
  - type: "RBAC"
    name: "rbac"
{{- end }}
{{- end -}}
