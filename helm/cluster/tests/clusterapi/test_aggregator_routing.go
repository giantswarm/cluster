package clusterapi

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var _ = Describe("API server aggregator routing", func() {
	const flagQuery = `select(.kind=="KubeadmControlPlane") | .spec.kubeadmConfigSpec.clusterConfiguration.apiServer.extraArgs[] | select(.name == "enable-aggregator-routing") | .value`

	It("does not render the flag by default", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"hello",
			"--set", "providerIntegration.useReleases=false",
		)

		Expect(strings.TrimSpace(yq.Run(manifests, flagQuery))).To(BeEmpty())
	})

	It("renders the flag on KubeadmControlPlane when enabled", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"hello",
			"--set", "providerIntegration.useReleases=false",
			"--set", "internal.advancedConfiguration.controlPlane.apiServer.enableAggregatorRouting=true",
		)

		Expect(strings.TrimSpace(yq.Run(manifests, flagQuery))).To(Equal("true"))
	})

	It("never renders the flag on KamajiControlPlane", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"test-kamaji-control-plane-values.yaml",
			"org-giantswarm",
			"kamaji-test",
			"--set", "providerIntegration.useReleases=false",
			"--set", "internal.advancedConfiguration.controlPlane.apiServer.enableAggregatorRouting=true",
		)

		Expect(manifests).NotTo(ContainSubstring("enable-aggregator-routing"))
	})
})
