# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).



## [Unreleased]

### Changed

- Update Kubernetes version to 1.25.16.

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

[Unreleased]: https://github.com/giantswarm/cluster/compare/v0.6.1...HEAD
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
