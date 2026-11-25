package components

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

// The security-bundle installs kubescape on the management cluster and leaves it to the bundle's
// own default (off) on workload clusters. A cluster is the management cluster when its name equals
// global.managementCluster. ci-values.yaml describes the workload cluster "awesome" on the
// management cluster "giantmc". See giantswarm/giantswarm#36109.
var _ = Describe("security-bundle kubescape default", func() {
	bundleValues := func(otherArgs ...string) string {
		args := append([]string{"--set", "providerIntegration.useReleases=false"}, otherArgs...)
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"awesome",
			args...,
		)

		return yq.Run(manifests, `select(.kind=="ConfigMap" and .metadata.name=="awesome-security-bundle-user-values") | .data.values`)
	}

	query := func(values, expression string) string {
		return strings.TrimSpace(yq.Run(values, expression))
	}

	It("doesn't set any app default on a workload cluster", func() {
		values := bundleValues()

		Expect(query(values, ".clusterID")).To(Equal("awesome"))
		Expect(query(values, ".apps")).To(Equal("null"))
	})

	It("enables kubescape on the management cluster", func() {
		values := bundleValues("--set", "global.managementCluster=awesome")

		Expect(query(values, ".clusterID")).To(Equal("awesome"))
		Expect(query(values, ".apps.kubescape.enabled")).To(Equal("true"))
	})

	It("lets the cluster's own values turn kubescape off on the management cluster", func() {
		values := bundleValues(
			"--set", "global.managementCluster=awesome",
			"--set", "global.apps.securityBundle.values.apps.kubescape.enabled=false",
		)

		Expect(query(values, ".apps.kubescape.enabled")).To(Equal("false"))
	})
})
