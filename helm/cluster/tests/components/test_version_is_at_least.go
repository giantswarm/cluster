package components

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

// cluster.app.version.isAtLeast gates app values on the app version in the Release. Dev builds
// (X.Y.Z-<build>) and release candidates are pre-release versions, which semverCompare leaves out
// of a range without a pre-release, so the helper must include them explicitly.
var _ = Describe("cluster.app.version.isAtLeast", func() {
	It("compares versions including release candidates and dev builds", func() {
		cases := map[string]bool{
			"N/A":                                    true,
			"0.5.0":                                  true,
			"0.5.1":                                  true,
			"1.0.0":                                  true,
			"0.5.0-rc.1":                             true,
			"0.5.1-r4c02ffect20261111214340h9a35588": true,
			"0.5.0-4c02ffe4c02ffe4c02ffe4c02ffe4c02ffe": true,
			"0.4.0":                                  false,
			"0.4.9":                                  false,
			"0.4.1-rb05cafcft20261006003606h0caf7a0": false,
		}

		// Render the internal helper through a test-only template in a copy of the chart, as
		// `helm template` cannot look up a Release resource.
		chartDir := GinkgoT().TempDir()
		Expect(os.CopyFS(chartDir, os.DirFS(helm.GetClusterChartDir()))).To(Succeed())

		var tpl strings.Builder
		tpl.WriteString("apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: version-is-at-least-test\ndata:\n")
		i := 0
		keys := map[string]string{}
		for version := range cases {
			key := fmt.Sprintf("case%d", i)
			keys[key] = version
			fmt.Fprintf(&tpl, `  %s: '{{ include "cluster.internal.version.isAtLeast" (dict "version" %q "minVersion" "0.5.0") }}'`+"\n", key, version)
			i++
		}
		Expect(os.WriteFile(filepath.Join(chartDir, "templates", "zz_version_is_at_least_test.yaml"), []byte(tpl.String()), 0o600)).To(Succeed())

		manifests := helm.Template(chartDir, "ci-values.yaml", "org-giantswarm", "awesome",
			"--show-only", "templates/zz_version_is_at_least_test.yaml")

		for key, version := range keys {
			result := strings.TrimSpace(yq.Run(manifests, fmt.Sprintf(".data.%s", key)))
			Expect(result == "true").To(Equal(cases[version]), "version %q: got %q", version, result)
		}
	})

	It("renders the cert-manager v4 values when the app version is unknown", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"awesome",
		)

		values := yq.Run(manifests, `select(.kind=="ConfigMap" and .metadata.name=="awesome-cert-manager-user-values") | .data.values`)
		Expect(yq.Run(values, `.cert-manager.dns01RecursiveNameserversOnly`)).To(Equal("true\n"))
		Expect(yq.Run(values, `has("dns01RecursiveNameserversOnly")`)).To(Equal("false\n"))
	})
})
