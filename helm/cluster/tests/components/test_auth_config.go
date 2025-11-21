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
	//go:embed files/auth_config_expected.yaml
	expectedAuthConfig string

	//go:embed files/auth_config_scenarios_expected.yaml
	expectedScenariosConfig string
)

var _ = Describe("auth config", func() {
	It("renders the correct authentication configuration", func() {
		helmValuesFile := "test-structured-auth-values.yaml"

		// Render all cluster chart manifests
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			helmValuesFile,
			"org-giantswarm",
			"hello",
			"--set", "providerIntegration.useReleases=false",
		)

		// Get auth config
		// The query extracts the decoded secret content for the auth-config
		// It looks for a Secret with name ending in "-control-plane-..." and containing the auth-config.yaml
		// Wait, the auth-config isn't in a Secret, it's in a KubeadmConfigTemplate -> .spec.template.spec.files

		// We need to extract the content from the file in KubeadmConfigTemplate
		kcpQuery := `select(.kind=="KubeadmControlPlane")`
		kcp := yq.Run(manifests, kcpQuery)

		// Check if the flag is set correctly in KubeadmControlPlane
		flagQuery := `.spec.kubeadmConfigSpec.clusterConfiguration.apiServer.extraArgs["authentication-config"]`
		authConfigFlag := yq.Run(kcp, flagQuery)
		Expect(strings.TrimSpace(authConfigFlag)).To(Equal("/etc/kubernetes/policies/auth-config.yaml"))

		// Check if the file content matches
		// The file is base64 encoded in the KubeadmControlPlane spec
		fileQuery := `.spec.kubeadmConfigSpec.files[] | select(.path=="/etc/kubernetes/policies/auth-config.yaml") | .content | @base64d`
		renderedAuthConfig := yq.Run(kcp, fileQuery)
		renderedAuthConfig = strings.TrimSpace(renderedAuthConfig)

		expectedConfig := strings.TrimSpace(expectedAuthConfig)
		Expect(renderedAuthConfig).To(Equal(expectedConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedConfig, renderedAuthConfig))
	})

	It("renders the correct authentication configuration for complex scenarios", func() {
		helmValuesFile := "test-cel-scenarios-values.yaml"

		// Render all cluster chart manifests
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			helmValuesFile,
			"org-giantswarm",
			"hello",
			"--set", "providerIntegration.useReleases=false",
		)

		kcpQuery := `select(.kind=="KubeadmControlPlane")`
		kcp := yq.Run(manifests, kcpQuery)

		fileQuery := `.spec.kubeadmConfigSpec.files[] | select(.path=="/etc/kubernetes/policies/auth-config.yaml") | .content | @base64d`
		renderedAuthConfig := yq.Run(kcp, fileQuery)
		renderedAuthConfig = strings.TrimSpace(renderedAuthConfig)

		expectedConfig := strings.TrimSpace(expectedScenariosConfig)
		Expect(renderedAuthConfig).To(Equal(expectedConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedConfig, renderedAuthConfig))
	})
})
