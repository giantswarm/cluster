package clusterapi

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var _ = Describe("Workers preKubeadmCommands template name", func() {
	nodePools := []string{"pool0", "pool1"}

	It("renders the provider template once per node pool", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"test-prekubeadmcommands-templatename-values.yaml",
			"org-giantswarm",
			"hooktest",
			"--set", "providerIntegration.useReleases=false",
		)

		for _, nodePool := range nodePools {
			query := "select(.kind==\"KubeadmConfig\" and .metadata.annotations[\"machine-pool.giantswarm.io/name\"]==\"hooktest-" + nodePool + "\") | .spec.preKubeadmCommands[]"
			commands := yq.Run(manifests, query)

			// The provider template sees the current node pool in $.nodePool.
			Expect(commands).To(ContainSubstring("provider command for node pool " + nodePool))

			// Commands rendered for other node pools must not leak into this KubeadmConfig.
			for _, other := range nodePools {
				if other == nodePool {
					continue
				}
				Expect(commands).NotTo(ContainSubstring("provider command for node pool " + other))
			}
		}
	})
})
