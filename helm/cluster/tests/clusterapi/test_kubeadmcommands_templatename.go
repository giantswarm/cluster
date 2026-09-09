package clusterapi

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var _ = Describe("Kubeadm commands template names", func() {
	nodePools := []string{"pool0", "pool1"}
	phases := []string{"pre", "post"}

	var manifests string

	BeforeEach(func() {
		manifests = helm.Template(
			helm.GetClusterChartDir(),
			"test-kubeadmcommands-templatename-values.yaml",
			"org-giantswarm",
			"hooktest",
			"--set", "providerIntegration.useReleases=false",
		)
	})

	It("renders the control plane provider templates once", func() {
		for _, phase := range phases {
			commands := yq.Run(manifests, "select(.kind==\"KubeadmControlPlane\") | .spec.kubeadmConfigSpec."+phase+"KubeadmCommands[]")

			Expect(commands).To(ContainSubstring("provider " + phase + " command for control plane"))

			// Commands of the other phase and of the worker templates must not leak into the control plane.
			Expect(commands).NotTo(ContainSubstring("provider " + otherPhase(phase) + " command"))
			Expect(commands).NotTo(ContainSubstring("command for node pool"))
		}
	})

	It("renders the worker provider templates once per node pool", func() {
		for _, nodePool := range nodePools {
			for _, phase := range phases {
				query := "select(.kind==\"KubeadmConfig\" and .metadata.annotations[\"machine-pool.giantswarm.io/name\"]==\"hooktest-" + nodePool + "\") | .spec." + phase + "KubeadmCommands[]"
				commands := yq.Run(manifests, query)

				// The provider template sees the current node pool in $.nodePool.
				Expect(commands).To(ContainSubstring("provider " + phase + " command for node pool " + nodePool))

				// Commands rendered for other node pools, for the other phase or for the control plane
				// must not leak into this KubeadmConfig.
				for _, other := range nodePools {
					if other == nodePool {
						continue
					}
					Expect(commands).NotTo(ContainSubstring("command for node pool " + other))
				}
				Expect(commands).NotTo(ContainSubstring("provider " + otherPhase(phase) + " command"))
				Expect(commands).NotTo(ContainSubstring("command for control plane"))
			}
		}
	})
})

func otherPhase(phase string) string {
	if phase == "pre" {
		return "post"
	}
	return "pre"
}
