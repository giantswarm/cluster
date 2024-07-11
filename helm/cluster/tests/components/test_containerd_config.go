package components

import (
	_ "embed"
	"fmt"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var (
	//go:embed files/containerd_expected_default.toml
	expectedContainerdDefaultConfig string

	//go:embed files/containerd_expected_zot_mc_only.toml
	expectedContainerdZotMcOnlyConfig string

	//go:embed files/containerd_expected_zot_local_only.toml
	expectedContainerdZotLocalOnlyConfig string

	//go:embed files/containerd_expected_zot_mc_and_local.toml
	expectedContainerdZotBothMcAndLocalConfig string
)

var _ = Describe("containerd config", func() {
	DescribeTable("rendered config file",
		func(helmValuesFile, expectedConfig string) {
			// Render all cluster chart manifests
			manifests := helm.Template(
				helm.GetClusterChartDir(),
				helmValuesFile,
				"org-giantswarm",
				"hello",
				"--set", "providerIntegration.useReleases=false",
			)

			// Get containerd config
			containerdConfigQuery := "select(.kind==\"Secret\") | select (.metadata.name | contains(\"containerd\")) | .data[\"config.toml\"] | @base64d"
			renderedContainerdConfig := yq.Run(manifests, containerdConfigQuery)
			renderedContainerdConfig = strings.TrimSpace(renderedContainerdConfig)

			expectedConfig = strings.TrimSpace(expectedConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedConfig, renderedContainerdConfig))
		},
		Entry("when only required and default Helm values are used", "test-required-values.yaml", expectedContainerdDefaultConfig),
		Entry("when only MC Zot is enabled", "test-zot-mc-values.yaml", expectedContainerdZotMcOnlyConfig),
		Entry("when only local Zot is enabled", "test-zot-only-local-values.yaml", expectedContainerdZotLocalOnlyConfig),
		Entry("when both local Zot and MC Zot are enabled", "test-zot-mc-and-local-values.yaml", expectedContainerdZotBothMcAndLocalConfig))

})
