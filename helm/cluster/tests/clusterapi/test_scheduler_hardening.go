package clusterapi

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var _ = Describe("Scheduler hardening", func() {
	It("renders the hardening flags on KubeadmControlPlane", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"ci-values.yaml",
			"org-giantswarm",
			"hello",
			"--set", "providerIntegration.useReleases=false",
		)

		flagValue := func(name string) string {
			query := `select(.kind=="KubeadmControlPlane") | .spec.kubeadmConfigSpec.clusterConfiguration.scheduler.extraArgs[] | select(.name == "` + name + `") | .value`
			return strings.TrimSpace(yq.Run(manifests, query))
		}

		Expect(flagValue("authentication-skip-lookup")).To(Equal("false"))
		Expect(flagValue("authentication-tolerate-lookup-failure")).To(Equal("false"))
		Expect(flagValue("permit-address-sharing")).To(Equal("false"))
		Expect(flagValue("permit-port-sharing")).To(Equal("false"))
		Expect(flagValue("profiling")).To(Equal("false"))
		Expect(flagValue("tls-cipher-suites")).To(ContainSubstring("TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"))
	})

	It("renders the hardening flags on KamajiControlPlane before the provider flags", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"test-kamaji-control-plane-values.yaml",
			"org-giantswarm",
			"kamaji-test",
			"--set", "providerIntegration.useReleases=false",
		)

		args := strings.Split(strings.TrimSpace(yq.Run(manifests, `select(.kind=="KamajiControlPlane") | .spec.scheduler.extraArgs[]`)), "\n")

		Expect(args).To(ContainElements(
			"--authentication-skip-lookup=false",
			"--authentication-tolerate-lookup-failure=false",
			"--permit-address-sharing=false",
			"--permit-port-sharing=false",
			"--profiling=false",
		))
		Expect(args).To(ContainElement(HavePrefix("--tls-cipher-suites=")))
		Expect(args[len(args)-1]).To(Equal("--bind-address=0.0.0.0"))
	})
})
