{{- define "cluster.internal.controlPlane.oidc.structuredAuthentication.config" -}}
{{- /* NOTE: Temporarily allowing 1.33+ for testing. Production should use 1.34+ */ -}}
{{- /* Use v1beta1 for Kubernetes 1.33.x (Beta), v1 for 1.34+ (GA) */ -}}
{{- $kubernetesVersion := include "cluster.component.kubernetes.version" $ | trimPrefix "v" -}}
{{- $apiVersion := "v1beta1" -}}
{{- if semverCompare ">=1.34.0-0" $kubernetesVersion -}}
  {{- $apiVersion = "v1" -}}
{{- end -}}
apiVersion: apiserver.config.k8s.io/{{ $apiVersion }}
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
          If a custom expression is provided, use it.
          Otherwise, construct an expression that concatenates the prefix (if any) with the claim value.
          Default claim is "sub" if not specified.
      */}}
      username:
          {{- $uExpression := "" }}
          {{- if $issuer.claimMappings }}
            {{- if $issuer.claimMappings.username }}
              {{- if $issuer.claimMappings.username.expression }}
                {{- $uExpression = $issuer.claimMappings.username.expression }}
              {{- end }}
            {{- end }}
          {{- end }}
          
          {{- if $uExpression }}
        expression: {{ $uExpression | quote }}
          {{- else }}
            {{- $uClaim := "sub" }}
            {{- $uPrefix := "" }}
            {{- if $issuer.claimMappings }}
               {{- if $issuer.claimMappings.username }}
                  {{- $uClaim = $issuer.claimMappings.username.claim | default ($issuer.usernameClaim | default "sub") }}
                  {{- $uPrefix = $issuer.claimMappings.username.prefix | default ($issuer.usernamePrefix | default "") }}
               {{- end }}
            {{- else }}
               {{- $uClaim = $issuer.usernameClaim | default "sub" }}
               {{- $uPrefix = $issuer.usernamePrefix | default "" }}
            {{- end }}
        expression: '{{ if $uPrefix }}"{{ $uPrefix }}" + {{ end }}claims["{{ $uClaim }}"]'
          {{- end }}

        {{- /* 
            Groups mapping:
            Constructs a CEL expression to handle group claims.
            - Checks if the claim exists.
            - Handles both string (single group) and list (multiple groups) claim types.
            - Prepends prefix if specified.
        */}}
        {{- $groupsExpression := "" }}
        {{- if $issuer.claimMappings }}
          {{- if $issuer.claimMappings.groups }}
            {{- if $issuer.claimMappings.groups.expression }}
              {{- $groupsExpression = $issuer.claimMappings.groups.expression }}
            {{- end }}
          {{- end }}
        {{- end }}

        {{- if not $groupsExpression }}
          {{- $gClaim := "" }}
          {{- $gPrefix := "" }}
          
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

          {{- if $gClaim }}
            {{- if $gPrefix }}
              {{- $groupsExpression = printf "has(claims['%s']) ? (type(claims['%s']) == string ? ['%s' + claims['%s']] : claims['%s'].map(g, '%s' + g)) : []" $gClaim $gClaim $gPrefix $gClaim $gClaim $gPrefix }}
            {{- else }}
              {{- $groupsExpression = printf "has(claims['%s']) ? (type(claims['%s']) == string ? [claims['%s']] : claims['%s']) : []" $gClaim $gClaim $gClaim $gClaim }}
            {{- end }}
          {{- end }}
        {{- end }}

      {{- if $groupsExpression }}
      groups:
        expression: {{ $groupsExpression | quote }}
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
