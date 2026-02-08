package clusterapi

import (
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster/helm/cluster/tests/helm"
	"github.com/giantswarm/cluster/helm/cluster/tests/yq"
)

var _ = Describe("Kamaji Control Plane", func() {
	It("renders KamajiControlPlane when kamaji provider is selected", func() {
		// Render all cluster chart manifests with Kamaji control plane configuration
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"test-kamaji-control-plane-values.yaml",
			"org-giantswarm",
			"kamaji-test",
			"--set", "providerIntegration.useReleases=false",
		)

		// Check that KamajiControlPlane resource exists
		query := "select(.kind==\"KamajiControlPlane\") | .apiVersion"
		apiVersion := yq.Run(manifests, query)
		Expect(strings.TrimSpace(apiVersion)).To(Equal("controlplane.cluster.x-k8s.io/v1alpha1"))

		// Check that basic spec fields are present
		query = "select(.kind==\"KamajiControlPlane\") | .spec | keys | sort"
		specKeys := yq.Run(manifests, query)
		Expect(specKeys).To(ContainSubstring("replicas"))
		Expect(specKeys).To(ContainSubstring("version"))
	})

	It("does NOT render KubeadmControlPlane when kamaji provider is selected", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"test-kamaji-control-plane-values.yaml",
			"org-giantswarm",
			"kamaji-test",
			"--set", "providerIntegration.useReleases=false",
		)

		query := "select(.kind==\"KubeadmControlPlane\")"
		kubeadmCP := yq.Run(manifests, query)
		Expect(strings.TrimSpace(kubeadmCP)).To(BeEmpty())
	})

	It("configures Cluster resource to reference KamajiControlPlane", func() {
		manifests := helm.Template(
			helm.GetClusterChartDir(),
			"test-kamaji-control-plane-values.yaml",
			"org-giantswarm",
			"kamaji-test",
			"--set", "providerIntegration.useReleases=false",
		)

		query := "select(.kind==\"Cluster\") | .spec.controlPlaneRef.kind"
		cpKind := yq.Run(manifests, query)
		Expect(strings.TrimSpace(cpKind)).To(Equal("KamajiControlPlane"))

		query = "select(.kind==\"Cluster\") | .spec.controlPlaneRef.apiVersion"
		cpAPIVersion := yq.Run(manifests, query)
		Expect(strings.TrimSpace(cpAPIVersion)).To(Equal("controlplane.cluster.x-k8s.io/v1alpha1"))
	})
})
