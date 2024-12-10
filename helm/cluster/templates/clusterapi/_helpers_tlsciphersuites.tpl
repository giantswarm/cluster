 {{- /*
    This file is for internal use only. It is used to define the list of TLS ciphersuites that are supported by the Kubernetes API server.
    The list of ciphersuites is based on the Kubernetes version and is used to configure the `tls-cipher-suites` parameter in the kube-apiserver and kubelet configuration files.
*/}}

{{- define "cluster.internal.kubeadm.tlsCipherSuites" -}}
{{- $k8sVersion := include "cluster.component.kubernetes.version" . | trimPrefix "v" }}
{{- $ciphers := list
  "TLS_AES_128_GCM_SHA256"
  "TLS_AES_256_GCM_SHA384"
  "TLS_CHACHA20_POLY1305_SHA256"
  "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA"
  "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
  "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA"
  "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
  "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
  "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"
  "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
  "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
  "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
  "TLS_RSA_WITH_AES_128_CBC_SHA"
  "TLS_RSA_WITH_AES_128_GCM_SHA256"
}}
{{- if semverCompare "<1.30.0" $k8sVersion }}
{{- $ciphers = concat $ciphers (list "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305" "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305") }}
{{- end }}
{{- toYaml $ciphers }}
{{- end }}
