# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Support `pauseProperties` with `null` values.
- Add MC Zot deployment as a registry mirror for `gsoci.azurecr.io` registry. This is the new default behavior.

### Added

- Tests for checking rendered containerd config.

## [0.36.0] - 2024-07-19

This release removes the `CronJobTimeZone` feature gate as it becomes stable and is included in Kubernetes v1.29.

For Kubernetes <v1.29, you will need to re-enable it using the respective values.

### Removed

- Feature Gates: Remove `CronJobTimeZone`. ([#267](https://github.com/giantswarm/cluster/pull/267))

## [0.35.0] - 2024-07-08

### Added

- Kubelet insecure mode

## [0.34.1] - 2024-07-05

### Fixed

- Restore single dependency for `k8s-audit-metrics` app.

## [0.34.0] - 2024-07-04

### Changed

- Enable `StatefulSetAutoDeletePVC` feature gate on all clusters.
- Update observability-bundle version from 1.3.4 to 1.4.0.
- Update cert-manager-app version from 3.7.7 to 3.7.8.

## [0.33.1] - 2024-07-02

### Added

- Add new `giantswarm-cluster-suite` app that provides basic Kubernetes resources others apps need in workload cluster.
- New flag that allows switching from Chart Operator backed App Platform to Flux backed App Platform.

### Changed

- Made `external-cloud-volume-plugin` setting optional in the controller-manger configuration.

## [0.33.0] - 2024-06-20

### Fixed

- Use app catalog from the Release CR if new releases are used.
- Use app dependencies from the Release CR if new releases are used.
- Add missing k8s-audit-metrics dependency (kyverno).

## [0.32.0] - 2024-06-18

### Added

- Add `.global.components.containerd.localRegistryCache` Helm values and support for in-cluster, local registry cache mirrors in `containerd` configuration.
  In such cases, the registry should be exposed via node ports and `containerd` connects via that port at `127.0.0.1` via HTTP (only allowed for this single use case).

## [0.31.4] - 2024-06-12

### Fixed

- Allow empty values in labels

## [0.31.3] - 2024-06-12

### Fixed

- Change Helm values validation so that `Values.global.release.version` object is not yet required.

## [0.31.2] - 2024-06-12

### Fixed

- Change Helm values validation so that `Values.global.release` object is not yet required.

## [0.31.1] - 2024-06-12

### Fixed

- Allow forward slashes in labels and annotations

## [0.31.0] - 2024-06-12

### Added

- This PR adds support for using Release CRs and getting Kubernetes, Flatcar and apps version, catalog and dependencies
  from there. This change is fully backward compatible, and it requires that new flag `$.Values.providerIntegration.useReleases`
  is set to `true`. The default value of `$.Values.providerIntegration.useReleases` is `false`, so cluster chart version
  can be safely updated.

## [0.30.1] - 2024-06-07

### Fixed

- Fix `prometheus-blackbox-exporter` and `k8s-audit-metrics` apps to use the correct chart name.

## [0.30.0] - 2024-06-06

### Added

- Add `prometheus-blackbox-exporter` and `k8s-audit-metrics` apps.

## [0.29.0] - 2024-05-31

### Fixed

- Set nodepool name on MachineHealth for MachineDeployments.

## [0.28.0] - 2024-05-30

### Fixed

- Fix wrong indentation for owner field of KubeadmConfig files.
- Fix `unable to select an IP from default routes` error by adding `network-online.target` as dependency for kubeadm service.

## [0.27.0] - 2024-05-28

### Added

- Add MachineDeployment resource template.
- Add MachineHealthCheck resource template to NodePools.
- API Server: Make feature gates configurable. ([#201](https://github.com/giantswarm/cluster/pull/201))\
  - Values: Make `providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.featureGates` reusable.
  - Values: Add `internal.advancedConfiguration.controlPlane.apiServer.featureGates`.
  - API Server: Implement `internal.advancedConfiguration.controlPlane.apiServer.featureGates`.
- Controller Manager: Make feature gates configurable. ([#203](https://github.com/giantswarm/cluster/pull/203))\
  - Values: Add `internal.advancedConfiguration.controlPlane.controllerManager.featureGates`.
  - Values: Add `providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.controllerManager.featureGates`.
  - Controller Manager: Implement `cluster.internal.controlPlane.kubeadm.clusterConfiguration.controllerManager.featureGates`.

### Changed

- **BREAKING** Replace `COREOS_EC2_HOSTNAME` with `Values.providerIntegration.environmentVariables.hostName` to support multiple providers.
- **BREAKING** Replace `COREOS_EC2_IPV4_LOCAL` with `Values.providerIntegration.environmentVariables.ipv4` to support multiple providers.

- Update cluster-autoscaler-app to 1.27.3-gs9.
- HelmReleases are deployed from a single generic template and details about apps that are deployed as HelmReleases are in `helm/cluster/files/helmreleases` (similarly to `helm/cluster/files/apps`).
- HelmReleases can be configured with `.Values.ephemeralConfiguration.<app name>` in the same way like App resources. Available values are:
  - `versionOverride` to override app version,
  - `catalogOverride` to override catalog (e.g. when you use development build version of your app), and
  - `disable` to disable rendering and deployment of the app.
- `chartName` is now optional when specifying app details in `helm/cluster/files/apps/<app name>.yaml` or `helm/cluster/files/helmreleases/<app name>.yaml`, and if it is not specified, `appName` property value will be used.
- `catalog` is now optional when specifying app details in `helm/cluster/files/apps/<app name>.yaml` or `helm/cluster/files/helmreleases/<app name>.yaml`, and if it is not specified, `"default"` value will be used.
- containerd: Append content hash to configuration secret name. ([#158](https://github.com/giantswarm/cluster/pull/158))\
  This ensures nodes roll whenever containerd configuration is changed.\
  **NOTE:** This also causes nodes to roll when upgrading to this version.

### ⚠️ Breaking changes for cluster-$provider apps

> _Note: This is NOT a breaking change for customers. Team Turtles handles updates of cluster chart in cluster-$provider apps and updates Helm values accordingly._

- Remove deprecated `.Values.providerIntegration.resourcesApi.ciliumHelmReleaseResourceEnabled` Helm value.
- Remove deprecated `.Values.providerIntegration.resourcesApi.coreDnsHelmReleaseResourceEnabled` Helm value.
- Remove deprecated `.Values.providerIntegration.resourcesApi.networkPoliciesHelmReleaseResourceEnabled` Helm value.
- Remove deprecated `.Values.providerIntegration.resourcesApi.verticalPodAutoscalerCrdHelmReleaseResourceEnabled` Helm value.

## [0.26.0] - 2024-05-16

### Added

- Restart containerd before kubeadm command.

## [0.25.0] - 2024-05-14

### ⚠️ Breaking changes

- Revert https://github.com/giantswarm/cluster/pull/152 because it introduced invalid containerd config which caused containerd to silently partially fail and not apply registry mirrors config.

## [0.24.0] - 2024-05-10

### Added

- Add capi-node-labeler app (disabled by default).
- Add cert-exporter app (disabled by default).
- Add cert-manager app (disabled by default).
- Add chart-operator-extensions app (disabled by default).
- Add cilium-servicemonitors app (disabled by default).
- Add cluster-autoscaler app (disabled by default).
- Add etcd-kubernetes-resources-count-exporter app (disabled by default).
- Add external-dns app (disabled by default).
- Add k8s-dns-node-cache app (disabled by default).
- Add metrics-server app (disabled by default).
- Add net-exporter app (disabled by default).
- Add node-exporter app (disabled by default).
- Add observability-bundle app (disabled by default).
- Add security-bundle app (disabled by default).
- Add teleport-kube-agent app (disabled by default).
- Add vertical-pod-autoscaler app (disabled by default).
- Add `$.Values.providerIntegration.apps.cilium.enable` flag to enable Cilium HelmRelease (old flag `$.Values.providerIntegration.resourcesApi.ciliumHelmReleaseResourceEnabled` is deprecated).
- Add `$.Values.providerIntegration.apps.coreDns.enable` flag to enable CoreDns HelmRelease (old flag `$.Values.providerIntegration.resourcesApi.coreDnsHelmReleaseResourceEnabled` is deprecated).
- Add `$.Values.providerIntegration.apps.networkPolicies.enable` flag to enable Network policies HelmRelease (old flag `$.Values.providerIntegration.resourcesApi.networkPoliciesHelmReleaseResourceEnabled` is deprecated).
- Add `$.Values.providerIntegration.apps.verticalPodAutoscalerCrd.enable` flag to enable Network policies HelmRelease (old flag `$.Values.providerIntegration.resourcesApi.verticalPodAutoscalerCrdHelmReleaseResourceEnabled` is deprecated).
- Add `$.Values.internal.ephemeralConfiguration.apps` config, meant only for development and temporary problem mitigation purposes, and where version and catalog can be overridden for every app.

### Fixed

- Fix CoreDNS provider-specific config (it was incorrectly reading Cilium app config instead of CoreDNS app config).
- Fix `containerd` configuration file.

### Changed

- Move `.internal.localRegistryCache` to `.global.components.containerd.localRegistryCache` to publicly expose the settings.

## [0.23.0] - 2024-05-08

### Added

- Render `KubeadmConfig.spec.containerLinuxConfig.additionalConfig.storage.filesystems` for machine pool workers to be able to configure additional disks.

## [0.22.0] - 2024-05-07

### Added

- Allow to set SELinux mode through `global.components.selinux.mode`.

## [0.21.0] - 2024-05-07

### Added

- Allow to set data directory for etcd.

## [0.20.0] - 2024-05-07

### Added

- Allow to set cloud-config path.
- Add `mounts` and `diskSystem` as spec fields for `KubeadmControlPlane`.

### Changed

- Upgrade cilium-app to v0.24.0 (cilium 1.15.4).


## [0.19.0] - 2024-04-25

- Upgrade cilium-app to v0.23.0 in order to make Cilium ENI mode for CAPA usable (adds subnet and security group selection filters)
- Add OS image to cluster chart schema, so it can be used by cluster-\<provider\> apps.

## [0.18.0] - 2024-03-28

### Changed

- Update teleport node labels - add `ins=` label and remove `cluster=` label condition check, such that MC nodes have this label.

## [0.17.0] - 2024-03-28

### Changed

- Update network-policies-app to v0.1.0.
- Update cilium to v0.22.0. This version includes schemas and the extra-policies deletion job.

## [0.16.0] - 2024-03-26

### Changed

- Disable unnecessary systemd unit `sshkeys.service`. ([#136](https://github.com/giantswarm/cluster/pull/136))

## [0.15.0] - 2024-03-26

### Added

- Chart: Add `ip` to Kubelet node labels. ([#125](https://github.com/giantswarm/cluster/pull/131))
- Chart: Add `providerIntegration.apps.networkPolicies` to be able to add provider specific network-policies helm values.
- Chart: Add `global.apps.networkPolicies` to allow customers to change network-policies helm values.
- Chart: Add `cluster-test` HelmRepository.

## [0.14.0] - 2024-03-21

### Added

- Chart: Add `providerIntegration.controlPlane.kubeadmConfig.clusterConfiguration.apiServer.serviceAccountIssuer.templateName` to be able set API Service Account Issuer via template.
- Chart: Add `providerIntegration.apps.coredns` to be able to add provider specific coredns helm values.
- Chart: Add `providerIntegration.registry` to be able to set the container registry value via template.

### Changed

- Chart: Make `internal.advancedConfiguration.controlPlane.controllerManager.terminatedPodGCThreshold` configurable. ([#123](https://github.com/giantswarm/cluster/pull/123))

### Fixed

- Typo on role in Cleanup HelmReleases Hook Job role. ([#124](https://github.com/giantswarm/cluster/pull/124))

## [0.13.0] - 2024-03-06

### Added

- Cleanup HelmRelease Hook Job.
- Chart: Make admission plugins configurable. ([#118](https://github.com/giantswarm/cluster/pull/118))
  - Chart: Add `internal.advancedConfiguration.controlPlane.apiServer.additionalAdmissionPlugins`.
  - Chart: Add `internal.advancedConfiguration.controlPlane.apiServer.admissionConfiguration`.

### Changed

- Chart: Improve `enable-admission-plugins` rendering. ([#113](https://github.com/giantswarm/cluster/pull/113))
- Chart: Split `cluster.internal.kubeadm.files.kubernetes` into `cluster.internal.controlPlane.kubeadm.files.*`. ([#117](https://github.com/giantswarm/cluster/pull/117))
- Chart: Make `additionalAdmissionPlugins` a reusable definition. ([#120](https://github.com/giantswarm/cluster/pull/120))

## [0.12.0] - 2024-02-29

### Changed

- Update cilium-app to v0.21.0 in order to support Cilium ENI mode for CAPA

## [0.11.1] - 2024-02-29

### Changed

- Fix order of preKubeadmCommands for CAPA migration, custom must be placed before any preKubadmCommands.

## [0.11.0] - 2024-02-28

### Changed

- Apply API Server fairness settings using patches.
- Randomize etcd defragmentation start minute so they are staggered.
- Fix order of preKubeadmCommands for CAPA migration, custom must be placed before provider commands.

## [0.10.0] - 2024-02-22

### Added

- Add cilium HelmRelease (behind a flag which is disabled by default).
- Add network-policies HelmRelease and cluster-catalog HelmRepository (behind a flag which is disabled by default).
- Kubelet: Add `containerLogMaxSize` & `containerLogMaxFiles`. ([#92](https://github.com/giantswarm/cluster/pull/92))
- API Server: Make audit policy rules extendable. ([#93](https://github.com/giantswarm/cluster/pull/93))

## [0.9.1] - 2024-02-22

### Changed

- Kubeadm: Use `kubeletconfiguration` patch target. ([#97](https://github.com/giantswarm/cluster/pull/97))

## [0.9.0] - 2024-02-21

### Added

- Add default HelmRepositories (behind a flag which is disabled by default).
- Add vertical-pod-autoscaler-crd HelmRelease (behind a flag which is disabled by default).
- Add coredns HelmRelease (behind a flag which is disabled by default).
- Support prepending cluster name to file secret name

### Changed

- Set `--node-ip` kubelet argument also for joining control plane nodes. Other nodes already had this setting, and it is important if a node has multiple network interfaces (such as for Cilium ENI mode or AWS VPC CNI). Only the primary IP will be reported in the node status, resulting in `kubectl exec` and other tooling working correctly.
- Put API server priority and fairness configuration behind a flag that is disabled by default.

## [0.8.0] - 2024-02-09

### Added

- Add systemd unit and script to compute fairness values for k8s API server in controlplane.
- Add internal.advancedConfiguration.kubelet to configure system and k8s reserved resources.
- Add `rolloutBefore` config to Helm value to `.Values.internal.advancedConfiguration.controlPlane` to enable support for automatic node rollout/certificate renewal
- Add systemd unit and timer for hourly etcd defragmentation.

### Changed

- Overridden default audit rules as in Vintage clusters.

### Fixed

- Fix MachinePool templates, so that AWSMachinePool correctly performs rolling updates (ported from https://github.com/giantswarm/cluster-aws/pull/457).

## [0.7.1] - 2024-01-31

### Fixed

- Fix MachineHealthCheck annotation rendering when custom annotations are not set.

## [0.7.0] - 2024-01-30

### Changed

- Update Kubernetes version to v1.25.16.
- Update CI values to remove features that do not exist anymore in Kubernetes v1.25.

### Fixed

- Remove labels from test Helm template for provider-specific machine template spec that is used in the CI.

## [0.6.1] - 2024-01-26

### Fixed
- Quote all etcd extra args, so they are correctly set as strings.

## [0.6.0] - 2024-01-25

### Added

- Add `global.podSecurityStandards.enforced` value which sets `policy.giantswarm.io/psp-status: disabled` label on the Cluster CR.

## [0.5.0] - 2024-01-25

### Added
- Add `quotaBackendBytesGiB` etcd config to Helm value `.Values.internal.advancedConfiguration.etcd`.

## [0.4.0] - 2024-01-24

### Added

- Add custom `files` config to Helm value to `.Values.internal.advancedConfiguration`.
- Add custom `preKubeadmCommands` config to Helm value to `.Values.internal.advancedConfiguration`.
- Add custom `postKubeadmCommands` config to Helm value to `.Values.internal.advancedConfiguration`.

### Changed

- Move API server `extraCertificateSANs` Helm value to `.Values.internal.advancedConfiguration.controlPlane.apiServer`.
- Move API server `extraArgs` Helm value to `.Values.internal.advancedConfiguration.controlPlane.apiServer`.
- Move API server `etcdPrefix` Helm value to `.Values.internal.advancedConfiguration.controlPlane.apiServer`.
- Move API server `bindPort` Helm value to `.Values.internal.advancedConfiguration.controlPlane.apiServer`.
- Move advanced etcd config to `.Values.internal.advancedConfiguration.controlPlane.etcd`.
- Use `gsoci.azurecr.io` for `kubeadm` container images (ported from https://github.com/giantswarm/cluster-aws/pull/482).
- Use `gsoci.azurecr.io` for sandbox container image (pause container) (ported from https://github.com/giantswarm/cluster-aws/pull/482).

### Fixed

- Fix typo in sandbox container scheme (ported from https://github.com/giantswarm/cluster-aws/pull/486).

## [0.3.1] - 2024-01-23

### Fixed

- Fix "cluster.connectivity.proxy.noProxy" template to correctly render values from specified template.

## [0.3.0] - 2024-01-22

### Changed

- Align API for properties that can be set as pre-defined static values and/or via templates.
- Improve NO_PROXY template: rename to cluster.connectivity.proxy.noProxy, make it public and usable from other charts.

## [0.2.1] - 2024-01-17

### Added

- Add `global.controlPlane.apiServerPort` value, configuring the Load Balancer port for the API

## [0.2.0] - 2024-01-17

### Added

- Enable using cgroupv1 (ported from https://github.com/giantswarm/cluster-aws/pull/410).
- Add systemd unit for OS hardening (ported from cluster-aws).
- Add systemd units for preventing in-place Flatcar OS updates (ported from cluster-aws).
- Add systemd unit for configuring kubeadm service (ported from cluster-aws).
- Add systemd unit for configuring containerd service (ported from cluster-aws).
- Add systemd unit for configuring audit-rules service (ported from cluster-aws).
- Add missing kubelet configuration to align it with vintage config (ported from https://github.com/giantswarm/cluster-aws/pull/468).
- Add /var/lib/kubelet as a default directory on all nodes.
- Add missing API server service-cluster-ip-range CLI argument 🙈.
- Add missing API server extra volumes.

### Changed

- Support longer node pool names and allow dashes (ported from https://github.com/giantswarm/cluster-aws/pull/429).
- Use KubeletConfiguration file instead of a bash script (ported from https://github.com/giantswarm/cluster-aws/pull/427).
- Update kubernetes version to 1.24.16.
- Enable Teleport by default.
- Update Teleport version to 14.1.3.
- Change JSON schema for systemd unit contents from string to object with explicitly defined fields.
- Render all SSH config conditionally behind a bastion flag.

### Fixed
- Fixed rendering of timesyncd configuration.
- Fix proxy Helm values schema.
- Fix API server timeoutForControlPlane config value.

## [0.1.2] - 2023-12-26

### Fixed

- Fix a typo in app label deprecation notice.

## [0.1.1] - 2023-12-21

### Added

- Add Helm value for specifying the provider name.
- Render `app: cluster-<provider>` label instead of `app: cluster` label.

### Fixed

- Fixed containerd configuration for newer flatcar versions.

## [0.1.0] - 2023-12-19

### Added

- Add Cluster resource template.
- Add KubeadmControlPlane resource template.
- Add MachineHealthCheck resource template.
- Add Flatcar configuration of systemd units and storage (filesystems and directories) in KubeadmControlPlane.
- Add Kubernetes API server configuration in KubeadmControlPlane.
- Add Kubernetes controller manager configuration in KubeadmControlPlane.
- Add Kubernetes scheduler configuration in KubeadmControlPlane.
- Add etcd configuration in KubeadmControlPlane.
- Add cluster networking configuration in KubeadmControlPlane.
- Add kubeadm init configuration in KubeadmControlPlane.
- Add kubeadm join configuration in KubeadmControlPlane.
- Add files configuration in KubeadmControlPlane.
- Add containerd configuration.
- Add Kubernetes audit policy.
- Add sshd configuration file.
- Add OIDC certificate configuration.
- Add kernel hardening configuration file.
- Add HTTP proxy configuration file
- Add timesyncd configuration file.
- Add teleport configuration file.
- Add required configuration and files for kubelet graceful shutdown.
- Add pre-kubeadm configuration in KubeadmControlPlane (commands that run before kubeadm).
- Add post-kubeadm configuration in KubeadmControlPlane (commands that run after kubeadm).
- Add users configuration in KubeadmControlPlane.
- Add control plane replicas configuration in KubeadmControlPlane.
- Add MachinePool resource template.
- Add KubeadmConfig resource template.
- Add Flatcar configuration of systemd units and storage (filesystems and directories) in MachinePool's KubeadmConfig.
- Add kubeadm init configuration in MachinePool's KubeadmConfig.
- Add kubeadm join configuration in MachinePool's KubeadmConfig.
- Add files configuration in MachinePool's KubeadmConfig.
- Add pre-kubeadm configuration in MachinePool's KubeadmConfig (commands that run before kubeadm).
- Add post-kubeadm configuration in MachinePool's KubeadmConfig (commands that run after kubeadm).
- Add users configuration in MachinePool's KubeadmConfig.
- Add bastion MachineDeployment resource template.
- Add bastion KubeadmConfigTemplate resource template.
- Add Flatcar configuration of systemd units in bastion KubeadmConfigTemplate.
- Add pre-kubeadm configuration (commands that run before kubeadm) in bastion KubeadmConfigTemplate.
- Add files configuration in bastion KubeadmConfigTemplate.
- Add users configuration in bastion KubeadmConfigTemplate.
- Expose much of the above configuration to be configurable via Helm values.
- Add JSON schema for Helm values.
- Add docs generation for Helm values schema.
- Use same Circle CI and GitHub actions like in provider-specific cluster-<provider> apps.
- Add app-build-suite config.
- Add same Makefile like in provider-specific cluster-<provider> apps.

### Changed

- Update and clean up the template repo.

[Unreleased]: https://github.com/giantswarm/cluster/compare/v0.36.0...HEAD
[0.36.0]: https://github.com/giantswarm/cluster/compare/v0.35.0...v0.36.0
[0.35.0]: https://github.com/giantswarm/cluster/compare/v0.34.1...v0.35.0
[0.34.1]: https://github.com/giantswarm/cluster/compare/v0.34.0...v0.34.1
[0.34.0]: https://github.com/giantswarm/cluster/compare/v0.33.2...v0.34.0
[0.33.2]: https://github.com/giantswarm/cluster/compare/v0.33.1...v0.33.2
[0.33.1]: https://github.com/giantswarm/cluster/compare/v0.33.0...v0.33.1
[0.33.0]: https://github.com/giantswarm/cluster/compare/v0.32.0...v0.33.0
[0.32.0]: https://github.com/giantswarm/cluster/compare/v0.31.4...v0.32.0
[0.31.4]: https://github.com/giantswarm/cluster/compare/v0.31.3...v0.31.4
[0.31.3]: https://github.com/giantswarm/cluster/compare/v0.31.2...v0.31.3
[0.31.2]: https://github.com/giantswarm/cluster/compare/v0.31.1...v0.31.2
[0.31.1]: https://github.com/giantswarm/cluster/compare/v0.31.0...v0.31.1
[0.31.0]: https://github.com/giantswarm/cluster/compare/v0.30.1...v0.31.0
[0.30.1]: https://github.com/giantswarm/cluster/compare/v0.30.0...v0.30.1
[0.30.0]: https://github.com/giantswarm/cluster/compare/v0.29.0...v0.30.0
[0.29.0]: https://github.com/giantswarm/cluster/compare/v0.28.0...v0.29.0
[0.28.0]: https://github.com/giantswarm/cluster/compare/v0.27.0...v0.28.0
[0.27.0]: https://github.com/giantswarm/cluster/compare/v0.26.0...v0.27.0
[0.26.0]: https://github.com/giantswarm/cluster/compare/v0.25.0...v0.26.0
[0.25.0]: https://github.com/giantswarm/cluster/compare/v0.24.0...v0.25.0
[0.24.0]: https://github.com/giantswarm/cluster/compare/v0.23.0...v0.24.0
[0.23.0]: https://github.com/giantswarm/cluster/compare/v0.22.0...v0.23.0
[0.22.0]: https://github.com/giantswarm/cluster/compare/v0.21.0...v0.22.0
[0.21.0]: https://github.com/giantswarm/cluster/compare/v0.20.0...v0.21.0
[0.20.0]: https://github.com/giantswarm/cluster/compare/v0.19.0...v0.20.0
[0.19.0]: https://github.com/giantswarm/cluster/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/giantswarm/cluster/compare/v0.17.0...v0.18.0
[0.17.0]: https://github.com/giantswarm/cluster/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/giantswarm/cluster/compare/v0.15.0...v0.16.0
[0.15.0]: https://github.com/giantswarm/cluster/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/giantswarm/cluster/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/giantswarm/cluster/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/giantswarm/cluster/compare/v0.11.1...v0.12.0
[0.11.1]: https://github.com/giantswarm/cluster/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/giantswarm/cluster/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/giantswarm/cluster/compare/v0.9.1...v0.10.0
[0.9.1]: https://github.com/giantswarm/cluster/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/giantswarm/cluster/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/giantswarm/cluster/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/giantswarm/cluster/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/giantswarm/cluster/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/giantswarm/cluster/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/giantswarm/cluster/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/giantswarm/cluster/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/giantswarm/cluster/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/giantswarm/cluster/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/cluster/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/giantswarm/cluster/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/giantswarm/cluster/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/giantswarm/cluster/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/cluster/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cluster/releases/tag/v0.1.0
