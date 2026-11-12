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

// cluster.app.version.satisfies gates app values on a semver constraint of the deployed app version.
// Dev builds (X.Y.Z-<build>) and release candidates are pre-release versions, which semverCompare
// leaves out of a constraint without a pre-release, so the helper compares them as X.Y.Z.
var _ = Describe("cluster.app.version.satisfies", func() {
	It("compares versions including release candidates and dev builds", func() {
		type testCase struct {
			constraint string
			version    string
			expected   string
		}
		cases := []testCase{
			{">=0.5.0", "N/A", "true"},
			{">=0.5.0", "0.5.0", "true"},
			{">=0.5.0", "0.5.1", "true"},
			{">=0.5.0", "1.0.0", "true"},
			{">=0.5.0", "0.5.0-rc.1", "true"},
			{">=0.5.0", "0.5.1-r4c02ffect20261111214340h9a35588", "true"},
			{">=0.5.0", "0.5.0-4c02ffe4c02ffe4c02ffe4c02ffe4c02ffe", "true"},
			{">=0.5.0", "v100.0.0-dev.8234y65dh92783", "true"},
			{">=0.5.0", "0.4.0", "false"},
			{">=0.5.0", "v0.4.0", "false"},
			{">=0.5.0", "0.4.9", "false"},
			{">=0.5.0", "0.4.1-rb05cafcft20261006003606h0caf7a0", "false"},
			{">=0.5.0", "latest", "false"},
			{">=0.5.0", "4c02ffe", "false"},
			{">=0.5.0", "1.2", "false"},
			{"<0.5.0", "0.4.1-rb05cafcft20261006003606h0caf7a0", "true"},
			{"<0.5.0", "0.5.0-rc.1", "false"},
			{"~0.5.0", "0.5.1-r4c02ffect20261111214340h9a35588", "true"},
			{"~0.5.0", "0.6.0", "false"},
			{">=0.5.0 <1.0.0", "0.9.0+build.1", "true"},
			{">=0.5.0 <1.0.0", "1.0.0-rc.1", "false"},
		}

		// Render the internal helper through a test-only template in a copy of the chart, as
		// `helm template` cannot look up a Release resource.
		chartDir := GinkgoT().TempDir()
		Expect(os.CopyFS(chartDir, os.DirFS(helm.GetClusterChartDir()))).To(Succeed())

		var tpl strings.Builder
		tpl.WriteString("apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: version-satisfies-test\ndata:\n")
		for i, c := range cases {
			fmt.Fprintf(&tpl, `  case%d: '{{ include "cluster.internal.version.satisfies" (dict "version" %q "constraint" %q) }}'`+"\n", i, c.version, c.constraint)
		}
		Expect(os.WriteFile(filepath.Join(chartDir, "templates", "zz_version_satisfies_test.yaml"), []byte(tpl.String()), 0o600)).To(Succeed())

		manifests := helm.Template(chartDir, "ci-values.yaml", "org-giantswarm", "awesome",
			"--show-only", "templates/zz_version_satisfies_test.yaml")

		for i, c := range cases {
			result := strings.TrimSpace(yq.Run(manifests, fmt.Sprintf(".data.case%d", i)))
			Expect(result).To(Equal(c.expected), "version %q, constraint %q", c.version, c.constraint)
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

	It("compares the ephemeral versionOverride instead of the Release version", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"awesome",
			"--set", "internal.ephemeralConfiguration.apps.certManager.versionOverride=3.9.0",
		)

		values := yq.Run(manifests, `select(.kind=="ConfigMap" and .metadata.name=="awesome-cert-manager-user-values") | .data.values`)
		Expect(yq.Run(values, `.dns01RecursiveNameserversOnly`)).To(Equal("true\n"))
		Expect(yq.Run(values, `has("cert-manager")`)).To(Equal("false\n"))
	})
})
