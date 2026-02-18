package clusterapi

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func TestClusterAPI(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "ClusterAPI Suite")
}
