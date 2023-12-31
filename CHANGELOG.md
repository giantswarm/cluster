# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).



## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/cluster/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/giantswarm/cluster/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/cluster/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cluster/releases/tag/v0.1.0
