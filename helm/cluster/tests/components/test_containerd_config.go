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

	//go:embed files/containerd_expected_without_cgroupsv1.toml
	expectedContainerdWithoutCgroupsv1Config string

	//go:embed files/containerd_nodepool_expected_without_cgroupsv1.toml
	expectedContainerdNodePoolWithoutCgroupsv1Config string

	//go:embed files/containerd_nodepool_expected_with_cgroupsv1.toml
	expectedContainerdNodePoolWithCgroupsv1Config string

	//go:embed files/containerd_expected_mirrors_registry.toml
	expectedContainerdDifferentMirrorsConfig string
)

var _ = Describe("containerd config", func() {
	DescribeTable("rendered control plane config file",
		func(helmValuesFile, expectedConfig string) {
			// Render all cluster chart manifests
			manifests := helm.Template(
				helm.GetClusterChartDir(),
				helmValuesFile,
				"org-giantswarm",
				"hello",
				"--set", "providerIntegration.useReleases=false",
			)

			// Get controlplane containerd config
			controlPlaneContainerdConfigQuery := "select(.kind==\"Secret\") | select (.metadata.name | contains(\"controlplane-containerd\")) | .data[\"config.toml\"] | @base64d"
			renderedControlPlaneContainerdConfig := yq.Run(manifests, controlPlaneContainerdConfigQuery)
			renderedControlPlaneContainerdConfig = strings.TrimSpace(renderedControlPlaneContainerdConfig)

			expectedConfig = strings.TrimSpace(expectedConfig)
			Expect(renderedControlPlaneContainerdConfig).To(Equal(expectedConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedConfig, renderedControlPlaneContainerdConfig))
		},
		Entry("when only required and default Helm values are used", "test-required-values.yaml", expectedContainerdDefaultConfig),
		Entry("when only MC Zot is enabled", "test-zot-mc-values.yaml", expectedContainerdZotMcOnlyConfig),
		Entry("when only local Zot is enabled", "test-zot-only-local-values.yaml", expectedContainerdZotLocalOnlyConfig),
		Entry("when both local Zot and MC Zot are enabled", "test-zot-mc-and-local-values.yaml", expectedContainerdZotBothMcAndLocalConfig),
		Entry("when node pools use cgroups v1, control plane always uses cgroups v2", "test-cgroupsv1-values.yaml", expectedContainerdWithoutCgroupsv1Config),
		Entry("when registry templates area used", "test-registry-mirrors-values.yaml", expectedContainerdDifferentMirrorsConfig))

	DescribeTable("rendered node pools config file",
		func(helmValuesFile, nodepoolName, expectedConfig string) {
			// Render all cluster chart manifests
			manifests := helm.Template(
				helm.GetClusterChartDir(),
				helmValuesFile,
				"org-giantswarm",
				"hello",
				"--set", "providerIntegration.useReleases=false",
			)

			// Get first node pool containerd config
			nodepoolContainerdConfigQuery := fmt.Sprintf("select(.kind==\"Secret\") | select (.metadata.name | contains(\"%s-containerd\")) | .data[\"config.toml\"] | @base64d", nodepoolName)
			renderedNodepoolContainerdConfig := yq.Run(manifests, nodepoolContainerdConfigQuery)
			renderedNodepoolContainerdConfig = strings.TrimSpace(renderedNodepoolContainerdConfig)

			expectedConfig = strings.TrimSpace(expectedConfig)
			Expect(renderedNodepoolContainerdConfig).To(Equal(expectedConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedConfig, renderedNodepoolContainerdConfig))
		},
		Entry("first node pool uses cgroupsv2", "test-cgroupsv1-values.yaml", "def00", expectedContainerdNodePoolWithoutCgroupsv1Config),
		Entry("second node pool uses cgroupsv2", "test-cgroupsv1-values.yaml", "def01", expectedContainerdNodePoolWithCgroupsv1Config),
		Entry("third node pool uses cgroupsv2", "test-cgroupsv1-values.yaml", "def02", expectedContainerdNodePoolWithoutCgroupsv1Config))

})
