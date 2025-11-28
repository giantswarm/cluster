{{- define "cluster.internal.controlPlane.oidc.structuredAuthentication.config" -}}
apiVersion: apiserver.config.k8s.io/v1
kind: AuthenticationConfiguration
jwt:
{{- $issuers := list }}
{{- /* Legacy configuration */}}
{{- if $.Values.global.controlPlane.oidc.issuerUrl }}
  {{- $legacyIssuer := dict
      "issuerUrl" $.Values.global.controlPlane.oidc.issuerUrl
      "clientId" $.Values.global.controlPlane.oidc.clientId
      "caPem" $.Values.global.controlPlane.oidc.caPem
      "usernameClaim" (default "sub" $.Values.global.controlPlane.oidc.usernameClaim)
      "usernamePrefix" (default "" $.Values.global.controlPlane.oidc.usernamePrefix)
      "groupsClaim" $.Values.global.controlPlane.oidc.groupsClaim
      "groupsPrefix" (default "" $.Values.global.controlPlane.oidc.groupsPrefix)
  -}}
  {{- $issuers = append $issuers $legacyIssuer }}
{{- end }}
{{- /* New configuration */}}
{{- range $.Values.global.controlPlane.oidc.structuredAuthentication.issuers }}
  {{- $issuers = append $issuers . }}
{{- end }}
{{- range $issuer := $issuers }}
  - issuer:
      url: {{ $issuer.issuerUrl | quote }}
      {{- if $issuer.discoveryUrl }}
      discoveryURL: {{ $issuer.discoveryUrl | quote }}
      {{- end }}
      audiences:
        {{- if $issuer.clientId }}
        - {{ $issuer.clientId | quote }}
        {{- end }}
        {{- range $issuer.audiences }}
        - {{ . | quote }}
        {{- end }}
      {{- if $issuer.audienceMatchPolicy }}
      audienceMatchPolicy: {{ $issuer.audienceMatchPolicy | quote }}
      {{- end }}
      {{- if $issuer.caPem }}
      certificateAuthority: |
        {{- $issuer.caPem | nindent 8 }}
      {{- end }}
    {{- if or $issuer.claimValidationRules $issuer.requiredClaims }}
    claimValidationRules:
    {{- range $rule := $issuer.claimValidationRules }}
      - {{ if $rule.claim }}claim: {{ $rule.claim | quote }}{{ end }}
        {{ if $rule.requiredValue }}requiredValue: {{ $rule.requiredValue | quote }}{{ end }}
        {{ if $rule.expression }}expression: {{ $rule.expression | quote }}{{ end }}
        {{ if $rule.message }}message: {{ $rule.message | quote }}{{ end }}
    {{- end }}
    {{- range $req := $issuer.requiredClaims }}
      - claim: {{ $req.claim | quote }}
        requiredValue: {{ $req.requiredValue | quote }}
    {{- end }}
    {{- end }}
    claimMappings:
      {{- /* 
          Username mapping:
          Configures how the username is derived from the OIDC token.
          
          Mutual Exclusion Rule:
          - If `expression` is provided, it takes precedence and is used as a CEL expression.
          - If `expression` is NOT provided, `claim` and `prefix` are used.
            - `claim`: The JWT claim to use (default: "sub").
            - `prefix`: The string to prepend to the claim value (required if claim is set, can be empty).
      */}}
      {{- $uExpression := "" }}
      {{- if $issuer.claimMappings }}
        {{- if $issuer.claimMappings.username }}
          {{- if $issuer.claimMappings.username.expression }}
            {{- $uExpression = $issuer.claimMappings.username.expression }}
          {{- end }}
        {{- end }}
      {{- end }}
      
      {{- $uClaim := "sub" }}
      {{- $uPrefix := "" }}
      {{- if not $uExpression }}
        {{- if $issuer.claimMappings }}
           {{- if $issuer.claimMappings.username }}
              {{- $uClaim = $issuer.claimMappings.username.claim | default ($issuer.usernameClaim | default "sub") }}
              {{- $uPrefix = $issuer.claimMappings.username.prefix | default ($issuer.usernamePrefix | default "") }}
           {{- end }}
        {{- else }}
           {{- $uClaim = $issuer.usernameClaim | default "sub" }}
           {{- $uPrefix = $issuer.usernamePrefix | default "" }}
        {{- end }}
      {{- end }}

      username:
      {{- if $uExpression }}
        expression: {{ $uExpression | quote }}
      {{- else }}
        claim: {{ $uClaim | quote }}
        prefix: {{ $uPrefix | quote }}
      {{- end }}

      {{- /* 
          Groups mapping:
          Configures how groups are derived from the OIDC token.
          
          Mutual Exclusion Rule:
          - If `expression` is provided, it takes precedence and is used as a CEL expression.
          - If `expression` is NOT provided, `claim` and `prefix` are used.
            - `claim`: The JWT claim to use (default: "groups").
            - `prefix`: The string to prepend to the claim value (required if claim is set, can be empty).
      */}}
      {{- $groupsExpression := "" }}
      {{- if $issuer.claimMappings }}
        {{- if $issuer.claimMappings.groups }}
          {{- if $issuer.claimMappings.groups.expression }}
            {{- $groupsExpression = $issuer.claimMappings.groups.expression }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{- $gClaim := "" }}
      {{- $gPrefix := "" }}
      {{- if not $groupsExpression }}
        {{- if $issuer.claimMappings }}
          {{- if $issuer.claimMappings.groups }}
             {{- $gClaim = $issuer.claimMappings.groups.claim | default ($issuer.groupsClaim) }}
             {{- $gPrefix = $issuer.claimMappings.groups.prefix | default ($issuer.groupsPrefix | default "") }}
          {{- end }}
        {{- end }}
        
        {{- if not $gClaim }}
           {{- $gClaim = $issuer.groupsClaim }}
           {{- $gPrefix = $issuer.groupsPrefix | default "" }}
        {{- end }}
      {{- end }}

      {{- if or $groupsExpression $gClaim }}
      groups:
        {{- if $groupsExpression }}
        expression: {{ $groupsExpression | quote }}
        {{- else }}
        claim: {{ $gClaim | quote }}
        prefix: {{ $gPrefix | quote }}
        {{- end }}
      {{- end }}
      {{- if $issuer.claimMappings }}
      {{- if $issuer.claimMappings.uid }}
      uid:
        {{- if $issuer.claimMappings.uid.expression }}
        expression: {{ $issuer.claimMappings.uid.expression | quote }}
        {{- else if $issuer.claimMappings.uid.claim }}
        claim: {{ $issuer.claimMappings.uid.claim | quote }}
        {{- end }}
      {{- end }}
      {{- if $issuer.claimMappings.extra }}
      extra:
        {{- range $extra := $issuer.claimMappings.extra }}
        - key: {{ $extra.key | quote }}
          valueExpression: {{ $extra.valueExpression | quote }}
        {{- end }}
        {{- end }}
        {{- end }}
      {{- if $issuer.userValidationRules }}
    userValidationRules:
    {{- range $rule := $issuer.userValidationRules }}
      - expression: {{ $rule.expression | quote }}
        {{- if $rule.message }}
        message: {{ $rule.message | quote }}
        {{- end }}
    {{- end }}
    {{- end }}
{{- end }}
{{- end -}}
