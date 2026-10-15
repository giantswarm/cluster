package components

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

// global.connectivity.cni.managed says whether Giant Swarm installs and operates the CNI. When it's
// false (e.g. AKS-managed networking), the cilium app is not rendered and no app depends on it.
// Release dependencies can't be rendered offline, so the static dependsOn from the app files is
// used instead. See giantswarm/giantswarm#38540.
var _ = Describe("global.connectivity.cni.managed", func() {
	render := func(managed string) string {
		return helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"awesome",
			"--set", "providerIntegration.useReleases=false",
			"--set", "global.connectivity.cni.managed="+managed,
		)
	}

	// yq separates the results from each document with "---".
	fields := func(output string) []string {
		var result []string
		for _, field := range strings.Fields(output) {
			if field != "---" {
				result = append(result, field)
			}
		}
		return result
	}

	ciliumResources := func(manifests string) []string {
		return fields(yq.Run(manifests, `select(.metadata.name=="awesome-cilium") | .kind`))
	}

	appsDependingOnCilium := func(manifests string) []string {
		names := yq.Run(manifests, `select(.kind=="HelmRelease" and (.spec.dependsOn // [] | any_c(.name=="awesome-cilium"))) | .metadata.name`)
		return fields(names)
	}

	It("renders cilium and its dependencies by default", func() {
		manifests := render("true")

		Expect(ciliumResources(manifests)).To(ConsistOf("OCIRepository", "HelmRelease"))
		Expect(appsDependingOnCilium(manifests)).To(ContainElements(
			"awesome-coredns",
			"awesome-network-policies",
			"awesome-cert-manager",
		))
	})

	It("renders neither cilium nor dependencies on it when the CNI isn't managed", func() {
		manifests := render("false")

		Expect(ciliumResources(manifests)).To(BeEmpty())
		Expect(appsDependingOnCilium(manifests)).To(BeEmpty())
		Expect(yq.Run(manifests, `select(.kind=="HelmRelease" and .metadata.name=="awesome-network-policies") | .metadata.name`)).NotTo(BeEmpty())
	})
})
