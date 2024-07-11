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
	//go:embed testfiles/containerd_expected_default.toml
	expectedContainerdDefaultConfig string

	//go:embed testfiles/containerd_expected_zot_mc.toml
	expectedContainerdZotMcConfig string

	//go:embed testfiles/containerd_expected_zot_local.toml
	expectedContainerdZotLocalConfig string
)

var _ = Describe("containerd config", func() {
	var testHelmValues string

	// cluster chart manifests
	var renderedContainerdConfig string

	JustBeforeEach(func() {
		// Render all cluster chart manifests
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			testHelmValues,
			"org-giantswarm",
			"hello",
			"--set", "providerIntegration.useReleases=false",
		)

		// Get containerd config
		containerdConfigQuery := "select(.kind==\"Secret\") | select (.metadata.name | contains(\"containerd\")) | .data[\"config.toml\"] | @base64d"
		renderedContainerdConfig = yq.Run(manifests, containerdConfigQuery)
		renderedContainerdConfig = strings.TrimSpace(renderedContainerdConfig)
	})

	When("only required and default Helm values are used", func() {
		BeforeEach(func() {
			testHelmValues = "test-required-values.yaml"
		})

		It("renders expected default containerd config", func() {
			expectedContainerdDefaultConfig = strings.TrimSpace(expectedContainerdDefaultConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedContainerdDefaultConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedContainerdDefaultConfig, renderedContainerdConfig))
		})
	})

	When("MC zot is enabled", func() {
		BeforeEach(func() {
			testHelmValues = "test-zot-mc-values.yaml"
		})

		It("renders expected containerd config with MC zot endpoints", func() {
			expectedContainerdZotMcConfig = strings.TrimSpace(expectedContainerdZotMcConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedContainerdZotMcConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedContainerdZotMcConfig, renderedContainerdConfig))
		})
	})

	When("local zot is enabled", func() {
		BeforeEach(func() {
			testHelmValues = "test-zot-local-values.yaml"
		})

		It("renders expected containerd config with local zot endpoints", func() {
			expectedContainerdZotLocalConfig = strings.TrimSpace(expectedContainerdZotLocalConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedContainerdZotLocalConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedContainerdZotLocalConfig, renderedContainerdConfig))
		})
	})
})
