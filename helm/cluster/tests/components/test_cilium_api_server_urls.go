package components

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

// Cilium discovers the API server URLs (k8s.apiServerURLs: auto) since cilium-app v1.7.0, so agents
// fail over to the kubernetes Service instead of depending on the API endpoint.
// See giantswarm/giantswarm#39246.
var _ = Describe("Cilium API server URL discovery", func() {
	const valuesQuery = `select(.kind=="ConfigMap" and .metadata.name=="awesome-cilium-user-values") | .data.values`

	render := func(chartDir string, args ...string) string {
		args = append([]string{"--set", "providerIntegration.useReleases=false"}, args...)
		return yq.Run(helm.Template(chartDir, "ci-values.yaml", "org-giantswarm", "awesome", args...), valuesQuery)
	}

	It("is enabled by default", func() {
		values := render(helm.GetClusterChartDir())
		Expect(yq.Run(values, `.k8s.apiServerURLs`)).To(Equal("auto\n"))
	})

	It("is enabled with cilium-app v1.7.0 release candidates", func() {
		values := render(helm.GetClusterChartDir(), "--set", "internal.ephemeralConfiguration.apps.cilium.versionOverride=1.7.0-rc.1")
		Expect(yq.Run(values, `.k8s.apiServerURLs`)).To(Equal("auto\n"))
	})

	It("is not set with cilium-app older than v1.7.0", func() {
		values := render(helm.GetClusterChartDir(), "--set", "internal.ephemeralConfiguration.apps.cilium.versionOverride=1.6.1")
		Expect(yq.Run(values, `has("k8s")`)).To(Equal("false\n"))
	})

	It("can be turned off by the provider", func() {
		chartDir := GinkgoT().TempDir()
		Expect(os.CopyFS(chartDir, os.DirFS(helm.GetClusterChartDir()))).To(Succeed())
		tpl := `{{- define "cluster.test.ciliumOptOut" }}
k8s:
  apiServerURLs: null
{{- end }}
`
		Expect(os.WriteFile(filepath.Join(chartDir, "templates", "_zz_cilium_opt_out_test.tpl"), []byte(tpl), 0o600)).To(Succeed())

		values := render(chartDir, "--set", "providerIntegration.apps.cilium.configTemplateName=cluster.test.ciliumOptOut")
		Expect(yq.Run(values, `.k8s.apiServerURLs`)).To(Equal("null\n"))
		Expect(yq.Run(values, `.k8sServiceHost`)).To(Equal("auto\n"))
	})
})
