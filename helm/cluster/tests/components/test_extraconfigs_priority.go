package components

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

// The App platform merged all configMaps before all secrets (secret always wins),
// and within each kind ordered extraConfigs by priority around the cluster-values
// (50) and user-values (100) slots. The migrated HelmReleases must reproduce that
// order in spec.valuesFrom, which Flux merges top-to-bottom. See the
// test-extraconfigs-priority-ordering-values.yaml file and giantswarm/giantswarm#36096.
var _ = Describe("extraConfigs priority ordering", func() {
	DescribeTable("renders valuesFrom in App-platform merge order",
		func(helmReleaseName, userValuesConfigMap string) {
			manifests := helm.Template(
				helm.GetClusterChartDir(),
				"test-extraconfigs-priority-ordering-values.yaml",
				"org-giantswarm",
				"awesome",
			)

			hr := yq.Run(manifests, `select(.kind=="HelmRelease" and .metadata.name=="`+helmReleaseName+`")`)
			order := yq.Run(hr, `.spec.valuesFrom[] | .kind + "/" + .name`)

			// configMaps first (by priority band, user-values at slot 100), then
			// secrets (by priority) — a secret always overrides a configMap.
			expected := []string{
				"ConfigMap/cm-pre-cluster",  // priority 20
				"ConfigMap/cm-default",      // priority 25 (defaulted)
				"ConfigMap/cm-pre-user",     // priority 90
				"ConfigMap/" + userValuesConfigMap, // user-values slot (100)
				"ConfigMap/cm-post-user",    // priority 120
				"Secret/sec-pre-cluster",    // priority 30
				"Secret/sec-pre-user",       // priority 90
				"Secret/sec-post-user",      // priority 130
			}
			Expect(strings.Fields(strings.TrimSpace(order))).To(Equal(expected))
		},
		Entry("WC-targeted app (cert-exporter)", "awesome-cert-exporter", "awesome-cert-exporter-user-values"),
		Entry("MC-targeted bundle (security-bundle)", "awesome-security-bundle", "awesome-security-bundle-user-values"),
	)
})
