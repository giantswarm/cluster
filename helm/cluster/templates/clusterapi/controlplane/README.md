# Cluster API resources for the control plane

## 1. Resources

- KubeadmControlPlane

## 2. Components

- API Server
- Controller manager
- Scheduler
- etcd

### 2.1. API Server

Options that we are setting:

| Option | Type | Used | Configurable | Value set | Upstream default value |
| --- | --- | --- | --- | --- | --- |
| admission-control-config-file | string | No | No | N/A | N/A |
| advertise-address | string | No | No | N/A | N/A |
| allow-metric-labels | stringToString | No | No | N/A | [] |
| allow-privileged | boolean | No | No | N/A | false |
| anonymous-auth | boolean | No | No | N/A | true |
| **api-audiences** | strings | Yes | Yes | N/A | service-account-issuer (if configured) |
| audit-log-batch-buffer-size | int | No | No | N/A | 10000 |
| audit-log-batch-max-size | int | No | No | N/A | 1 |
| audit-log-batch-max-wait | duration | No | No | N/A | N/A |
| audit-log-batch-throttle-burst | int | No | No | N/A | N/A |
| audit-log-batch-throttle-enable | boolean | No | No | N/A | N/A |
| audit-log-batch-throttle-qps | float | No | No | N/A | N/A |
| audit-log-compress | boolean | No | No | N/A | N/A |
| audit-log-format | string | No | No | N/A | json |
| **audit-log-maxage** | int | Yes | No | 30 | N/A |
| **audit-log-maxbackup** | int | Yes | No | 30 | N/A |
| **audit-log-maxsize** | int | Yes | No | 100 | N/A |
| audit-log-mode | string | No | No | N/A | blocking |
| **audit-log-path** | string | Yes | No | /var/log/apiserver/audit.log | N/A |
| audit-log-truncate-enabled | boolean | No | No | N/A | N/A |
| audit-log-truncate-max-batch-size | int | No | No | N/A | 10485760 |
| audit-log-truncate-max-event-size | int | No | No | N/A | 102400 |
| audit-log-version | string | No | No | N/A | audit.k8s.io/v1 |
| **audit-policy-file** | string | Yes | No | /etc/kubernetes/policies/audit-policy.yaml | N/A |
| audit-webhook-batch-buffer-size | int | No | No | N/A | 10000 |
| audit-webhook-batch-max-size | int | No | No | N/A | 400 |
| audit-webhook-batch-max-wait | duration | No | No | N/A | 30s |
| audit-webhook-batch-throttle-burst | int | No | No | N/A | 15 |
| audit-webhook-batch-throttle-enable | boolean | No | No | N/A | true |
| audit-webhook-batch-throttle-qps | float | No | No | N/A | 10 |
| audit-webhook-config-file | string | No | No | N/A | N/A |
| audit-webhook-initial-backoff | duration | No | No | N/A | 10s |
| audit-webhook-mode string | string | No | No | N/A | batch |
| audit-webhook-truncate-enabled | boolean | No | No | N/A | N/A |
| audit-webhook-truncate-max-batch-size | int | No | No | N/A | 10485760 |
| audit-webhook-truncate-max-event-size | int | No | No | N/A | 102400 |
| audit-webhook-version | string | No | No | N/A | audit.k8s.io/v1 |
| authentication-token-webhook-cache-ttl | duration | No | No | N/A | 2m0s |
| authentication-token-webhook-config-file | string | No | No | N/A | N/A |
| authentication-token-webhook-version | string | No | No | N/A | v1beta1 |
| authorization-mode | strings | No | No | N/A | AlwaysAllow |
| authorization-policy-file | string | No | No | N/A | N/A |
| authorization-webhook-cache-authorized-ttl | duration | No | No | N/A | 5m0s |
| authorization-webhook-cache-unauthorized-ttl | duration | No | No | N/A | 30s |
| authorization-webhook-config-file | string | No | No | N/A | N/A |
| authorization-webhook-version | string | No | No | N/A | v1beta1 |
| azure-container-registry-config | string | No | No | N/A | N/A |
| bind-address | string | No | No | N/A | 0.0.0.0 |
| cert-dir | string | No | No | N/A | /var/run/kubernetes |
| client-ca-file | string | No | No | N/A | N/A |
| cloud-config | string | No | No | N/A | N/A |
| **cloud-provider** | string | Yes | No | external | N/A |
| cloud-provider-gce-l7lb-src-cidrs | cidrs | No | No | N/A | 130.211.0.0/22,35.191.0.0/16 |
| contention-profiling | boolean | No | No | N/A | N/A |
| cors-allowed-origins | strings | No | No | N/A | N/A |
| default-not-ready-toleration-seconds | int | No | No | N/A | 300 |
| default-unreachable-toleration-seconds | int | No | No | N/A | 300 |
| default-watch-cache-size | int | No | No | N/A | 100 |
| delete-collection-workers | int | No | No | N/A | 1 |
| disable-admission-plugins | strings | No | No | N/A | N/A |
| disabled-metrics | strings | No | No | N/A | N/A |
| egress-selector-config-file | string | No | No | N/A | N/A |
| **enable-admission-plugins** | strings | Yes | Yes | DefaultStorageClass, DefaultTolerationSeconds, LimitRanger, MutatingAdmissionWebhook, NamespaceLifecycle, PersistentVolumeClaimResize, Priority, ResourceQuota, ServiceAccount, ValidatingAdmissionWebhook | CertificateApproval, CertificateSigning, CertificateSubjectRestriction, ClusterTrustBundleAttest, DefaultIngressClass, DefaultStorageClass, DefaultTolerationSeconds, LimitRanger, MutatingAdmissionWebhook, NamespaceLifecycle, PersistentVolumeClaimResize, PodSecurity, Priority, ResourceQuota, RuntimeClass, ServiceAccount, StorageObjectInUseProtection, TaintNodesByCondition, ValidatingAdmissionPolicy, ValidatingAdmissionWebhook |
| enable-aggregator-routing | boolean | No | No | N/A | N/A |
| enable-bootstrap-token-auth | boolean | No | No | N/A | N/A |
| enable-garbage-collector | boolean | No | No | N/A | true |
| enable-priority-and-fairness | boolean | No | No | N/A | true |
| **encryption-provider-config** | string | Yes | No | /etc/kubernetes/encryption/config.yaml | No |
| endpoint-reconciler-type | string | No | No | N/A | lease |
| etcd-cafile | string | No | No | N/A | N/A |
| etcd-certfile | string | No | No | N/A | N/A |
| etcd-compaction-interval | duration | No | No | N/A | 5m0s |
| etcd-count-metric-poll-period | duration | No | No | N/A | 1m0s |
| etcd-db-metric-poll-interval | duration | No | No | N/A | 30s |
| etcd-healthcheck-timeout | duration | No | No | N/A | 2s |
| etcd-keyfile | string | No | No | N/A | N/A |
| etcd-prefix | string | No | No | N/A | /registry |
| etcd-servers | strings | No | No | N/A | N/A |
| etcd-servers-overrides | strings | No | No | N/A | N/A |
| event-ttl | duration | No | No | N/A | 1h0m0s |
| external-hostname | string | No | No | N/A | N/A |
| **feature-gates** | map\[string\]\[True\|False\] | Yes | No | CronJobTimeZone=true | APIListChunking=true,<br/>APIPriorityAndFairness=true,<br/>APIResponseCompression=true,<br/>APIServerIdentity=true,<br/>APIServerTracing=true,<br/>AdmissionWebhookMatchConditions=true,<br/>AggregatedDiscoveryEndpoint=true,<br/>AnyVolumeDataSource=true,<br/>AppArmor=true,<br/>CPUManagerPolicyBetaOptions=true,<br/>CPUManagerPolicyOptions=true,<br/>CSINodeExpandSecret=true,<br/>ComponentSLIs=true,<br/>CronJobsScheduledAnnotation=true,<br/>CustomResourceValidationExpressions=true,<br/>ElasticIndexedJob=true,<br/>GracefulNodeShutdown=true,<br/>GracefulNodeShutdownBasedOnPodPriority=true,<br/>HPAContainerMetrics=true,<br/>JobPodFailurePolicy=true,<br/>JobReadyPods=true,<br/>KMSv2=true,<br/>KubeletTracing=true,<br/>LogarithmicScaleDown=true,<br/>LoggingBetaOptions=true,<br/>MatchLabelKeysInPodTopologySpread=true,<br/>MemoryManager=true,<br/>MinDomainsInPodTopologySpread=true,<br/>NewVolumeManagerReconstruction=true,<br/>NodeInclusionPolicyInPodTopologySpread=true,<br/>OpenAPIEnums=true,<br/>PDBUnhealthyPodEvictionPolicy=true,<br/>PodDeletionCost=true,<br/>PodDisruptionConditions=true,<br/>PodIndexLabel=true,<br/>PodSchedulingReadiness=true,<br/>ReadWriteOncePod=true,<br/>RemainingItemCount=true,<br/>RotateKubeletServerCertificate=true,<br/>SELinuxMountReadWriteOncePod=true,<br/>SchedulerQueueingHints=true,<br/>ServiceNodePortStaticSubrange=true,<br/>SizeMemoryBackedVolumes=true,<br/>StableLoadBalancerNodeSet=true,<br/>StatefulSetAutoDeletePVC=true,<br/>StatefulSetStartOrdinal=true,<br/>StorageVersionHash=true,<br/>TopologyAwareHints=true,<br/>TopologyManagerPolicyBetaOptions=true,<br/>TopologyManagerPolicyOptions=true,<br/>WinOverlay=true,<br/>WindowsHostNetwork=true |
| goaway-chance | float | No | No | N/A | N/A |
| http2-max-streams-per-connection | int | No | No | N/A | golang's default |
| identity-lease-duration-seconds | int | No | No | N/A | 3600 |
| identity-lease-renew-interval-seconds | int | No | No | N/A | 10 |
| kubelet-certificate-authority | string | No | No | N/A | N/A |
| kubelet-client-certificate | string | No | No | N/A | N/A |
| kubelet-client-key | string | No | No | N/A | N/A |
| **kubelet-preferred-address-types** | strings | Yes | No | InternalIP | Hostname,InternalDNS,InternalIP,ExternalDNS,ExternalIP |
| kubelet-timeout | duration | No | No | N/A | 5s |
| kubernetes-service-node-port | int | No | No | N/A | N/A |
| lease-reuse-duration-seconds | int | No | No | N/A | 60 |
| livez-grace-period | duration | No | No | N/A | N/A |
| log-flush-frequency | duration | No | No | N/A | 5s |
| logging-format | string | No | No | N/A | text |
| master-service-namespace | string | No | No | N/A | default |
| max-connection-bytes-per-sec | int | No | No | N/A | N/A |
| max-mutating-requests-inflight | int | No | No | N/A | 200 |
| max-requests-inflight | int | No | No | N/A | 400 |
| min-request-timeout | int | No | No | N/A | 1800 |
| **oidc-ca-file** | string | Yes | No | /etc/ssl/certs/oidc.pem (if OIDC CA has been specified) | host's root CA set |
| **oidc-client-id** | string | Yes | Yes | N/A | N/A |
| **oidc-groups-claim** | string | Yes | Yes | N/A | N/A |
| oidc-groups-prefix | string | No | No | N/A | N/A |
| **oidc-issuer-url** | string | Yes | Yes | N/A | N/A |
| oidc-required-claim | comma-separated 'key=value' pairs | No | No | N/A | N/A |
| oidc-signing-algs | strings | No | No | N/A | RS256 |
| **oidc-username-claim** | string | Yes | Yes | N/A | sub |
| oidc-username-prefix | string | No | No | N/A | N/A |
| permit-address-sharing | boolean | No | No | N/A | false |
| permit-port-sharing | boolean | No | No | N/A | false |
| **profiling** | boolean | Yes | No | false | true |
| proxy-client-cert-file | string | No | No | N/A | N/A |
| proxy-client-key-file | string | No | No | N/A | N/A |
| request-timeout | duration | No | No | N/A | 1m0s |
| requestheader-allowed-names | strings | No | No | N/A | N/A |
| requestheader-client-ca-file | string | No | No | N/A | N/A |
| requestheader-extra-headers-prefix | strings | No | No | N/A | N/A |
| requestheader-group-headers | strings | No | No | N/A | N/A |
| requestheader-username-headers | strings | No | No | N/A | N/A |
| **runtime-config** | comma-separated 'key=value' pairs | Yes | No | api/all=true | N/A |
| secure-port | int | No | No | N/A | 6443 |
| service-account-extend-token-expiration | boolean | No | No | N/A | true |
| **service-account-issuer** | strings | Yes | Yes | N/A | N/A |
| service-account-jwks-uri | string | No | No | N/A | N/A |
| service-account-key-file | strings | No | No | N/A | N/A |
| **service-account-lookup** | boolean | Yes | No | true | true |
| service-account-max-token-expiration | duration | No | No | N/A | N/A |
| service-account-signing-key-file | string | No | No | N/A | N/A |
| service-cluster-ip-range | string | No | No | N/A | N/A |
| service-node-port-range | a string in the form 'N1-N2' | No | No | N/A | 30000-32767 |
| show-hidden-metrics-for-version | string | No | No | N/A | N/A |
| shutdown-delay-duration | duration | No | No | N/A | N/A |
| shutdown-send-retry-after | boolean | No | No | N/A | N/A |
| storage-backend | string | No | No | N/A | N/A |
| storage-media-type | string | No | No | N/A | application/vnd.kubernetes.protobuf |
| strict-transport-security-directives | strings | No | No | N/A | N/A |
| tls-cert-file | string | No | No | N/A | N/A |
| **tls-cipher-suites** | strings | Yes | No | Preferred values:<br/>TLS_AES_128_GCM_SHA256,<br/>TLS_AES_256_GCM_SHA384,<br/>TLS_CHACHA20_POLY1305_SHA256,<br/>TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,<br/>TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,<br/>TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,<br/>TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,<br/>TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,<br/>TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,<br/>TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,<br/>TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,<br/>TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,<br/>TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,<br/>TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,<br/>TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,<br/>TLS_RSA_WITH_AES_128_CBC_SHA,<br/>TLS_RSA_WITH_AES_128_GCM_SHA256,<br/>TLS_RSA_WITH_AES_256_CBC_SHA,<br/>TLS_RSA_WITH_AES_256_GCM_SHA384 | default Go cipher suites |
| tls-min-version | string | No | No | N/A | N/A |
| tls-private-key-file | string | No | No | N/A | N/A |
| tls-sni-cert-key | string | No | No | N/A | N/A |
| token-auth-file | string | No | No | N/A | N/A |
| tracing-config-file | string | No | No | N/A | N/A |
| version | boolean | No | No | N/A | N/A |
| vmodule | pattern=N,... | No | No | N/A | N/A |
| watch-cache-sizes | strings | No | No | N/A | N/A |
| watch-cache | boolean | No | No | N/A | true |
