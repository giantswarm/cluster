package components

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

// Provider charts can add extraConfigs to an app via providerIntegration.apps.<app>.extraConfigs,
// e.g. a ConfigMap written by an operator once the cluster is provisioned. Their names are rendered
// as templates, and at equal priority they come before the user's extraConfigs.
var _ = Describe("providerIntegration.apps extraConfigs", func() {
	It("renders provider extraConfigs before user extraConfigs in valuesFrom", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"awesome",
			"--set", "providerIntegration.useReleases=false",
			"--set", "providerIntegration.apps.certExporter.enable=true",
			"--set-json", `providerIntegration.apps.certExporter.extraConfigs=[{"kind":"ConfigMap","name":"{{ include \"cluster.resource.name\" $ }}-provider-config"}]`,
			"--set-json", `global.apps.certExporter.extraConfigs=[{"kind":"ConfigMap","name":"user-config"}]`,
		)

		hr := yq.Run(manifests, `select(.kind=="HelmRelease" and .metadata.name=="awesome-cert-exporter")`)
		order := yq.Run(hr, `.spec.valuesFrom[] | .kind + "/" + .name`)

		Expect(strings.Fields(strings.TrimSpace(order))).To(Equal([]string{
			"ConfigMap/awesome-provider-config",
			"ConfigMap/user-config",
			"ConfigMap/awesome-cert-exporter-user-values",
		}))
	})
})
