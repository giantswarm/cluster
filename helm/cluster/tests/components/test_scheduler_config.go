package components

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var _ = Describe("Scheduler Security Configuration", func() {
	var (
		manifests string
	)

	Context("when using default values", func() {
		BeforeEach(func() {
			manifests = helm.Template(
				helm.GetClusterChartDir(),
				"test-required-values.yaml",
				"org-giantswarm",
				"test-cluster",
				"--set", "providerIntegration.useReleases=false",
			)
		})

		It("should have secure bind address configured", func() {
			bindAddressQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs[\"bind-address\"]"
			bindAddress := yq.Run(manifests, bindAddressQuery)
			bindAddress = strings.TrimSpace(bindAddress)
			Expect(bindAddress).To(Equal("127.0.0.1"), "Scheduler bind address should be restricted to localhost for security (CIS 1.4.1)")
		})

		It("should have profiling disabled", func() {
			profilingQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs.profiling"
			profiling := yq.Run(manifests, profilingQuery)
			profiling = strings.TrimSpace(profiling)
			Expect(profiling).To(Equal("false"), "Scheduler profiling should be disabled for security (CIS 1.4.2)")
		})

		It("should have authentication kubeconfig configured", func() {
			authKubeconfigQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs[\"authentication-kubeconfig\"]"
			authKubeconfig := yq.Run(manifests, authKubeconfigQuery)
			authKubeconfig = strings.TrimSpace(authKubeconfig)
			Expect(authKubeconfig).To(Equal("/etc/kubernetes/scheduler.conf"), "Scheduler authentication kubeconfig should be configured for security")
		})

		It("should have authorization kubeconfig configured", func() {
			authzKubeconfigQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs[\"authorization-kubeconfig\"]"
			authzKubeconfig := yq.Run(manifests, authzKubeconfigQuery)
			authzKubeconfig = strings.TrimSpace(authzKubeconfig)
			Expect(authzKubeconfig).To(Equal("/etc/kubernetes/scheduler.conf"), "Scheduler authorization kubeconfig should be configured for security")
		})

		It("should maintain existing authorization paths", func() {
			authPathsQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs[\"authorization-always-allow-paths\"]"
			authPaths := yq.Run(manifests, authPathsQuery)
			authPaths = strings.TrimSpace(authPaths)
			Expect(authPaths).To(Equal("/healthz,/readyz,/livez,/metrics"), "Scheduler should maintain existing authorization paths for monitoring")
		})
	})

	Context("scheduler security hardening compliance", func() {
		BeforeEach(func() {
			manifests = helm.Template(
				helm.GetClusterChartDir(),
				"test-required-values.yaml",
				"org-giantswarm",
				"test-cluster",
				"--set", "providerIntegration.useReleases=false",
			)
		})

		It("should pass CIS Kubernetes Benchmark 1.4.1 - bind address check", func() {
			bindAddressQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs[\"bind-address\"]"
			bindAddress := yq.Run(manifests, bindAddressQuery)
			bindAddress = strings.TrimSpace(bindAddress)
			Expect(bindAddress).NotTo(Equal("0.0.0.0"), "CIS 1.4.1: Scheduler should not bind to all interfaces")
			Expect(bindAddress).To(Equal("127.0.0.1"), "CIS 1.4.1: Scheduler should bind only to localhost")
		})

		It("should pass CIS Kubernetes Benchmark 1.4.2 - profiling check", func() {
			profilingQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs.profiling"
			profiling := yq.Run(manifests, profilingQuery)
			profiling = strings.TrimSpace(profiling)
			Expect(profiling).To(Equal("false"), "CIS 1.4.2: Scheduler profiling should be disabled")
		})

		It("should have all required security parameters configured", func() {
			schedulerArgsQuery := "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs"
			schedulerArgs := yq.Run(manifests, schedulerArgsQuery)

			// Verify all required security parameters are present
			Expect(schedulerArgs).To(ContainSubstring("bind-address"), "Missing bind-address configuration")
			Expect(schedulerArgs).To(ContainSubstring("profiling"), "Missing profiling configuration")
			Expect(schedulerArgs).To(ContainSubstring("authentication-kubeconfig"), "Missing authentication configuration")
			Expect(schedulerArgs).To(ContainSubstring("authorization-kubeconfig"), "Missing authorization configuration")
		})
	})

	Context("when validating template rendering", func() {
		It("should render valid YAML with scheduler configuration", func() {
			manifests := helm.Template(
				helm.GetClusterChartDir(),
				"test-required-values.yaml",
				"org-giantswarm",
				"test-cluster",
				"--set", "providerIntegration.useReleases=false",
			)

			Expect(manifests).NotTo(BeEmpty())

			// Verify the scheduler configuration is present in the rendered output
			Expect(manifests).To(ContainSubstring("scheduler:"), "Scheduler configuration should be present in rendered template")
			Expect(manifests).To(ContainSubstring("bind-address: 127.0.0.1"), "Secure bind address should be rendered")
			Expect(manifests).To(ContainSubstring("profiling: false"), "Disabled profiling should be rendered")
		})
	})
})
