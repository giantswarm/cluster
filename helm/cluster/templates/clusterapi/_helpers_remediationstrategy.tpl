{{- define "cluster.internal.advancedConfiguration.remediationStrategy" }}
maxRetry: {{ .maxRetry | default 5 }}
retryPeriod: {{ .retryPeriod | default "2m" | quote }}
minHealthyPeriod: {{ .minHealthyPeriod | default "2h" | quote }}
{{- end }}
