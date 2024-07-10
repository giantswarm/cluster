package components

import (
	"bytes"
	_ "embed"
	"encoding/base64"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var (
	//go:embed testfiles/containerd_zot_local_expected.toml
	expectedContainerdZotLocalConfig string

	//go:embed testfiles/containerd_zot_mc_expected.toml
	expectedContainerdZotMcConfig string
)

var _ = Describe("containerd config", func() {
	var testHelmValues string

	// cluster chart manifests
	var renderedContainerdConfig string

	JustBeforeEach(func() {
		// get cluster chart root directory
		// Get the current file path
		_, currentFilePath, _, ok := runtime.Caller(0)
		Expect(ok).To(BeTrue())
		componentsDir := filepath.Dir(currentFilePath)
		testsDir := filepath.Dir(componentsDir)
		chartDir := filepath.Dir(testsDir)

		// Now create command to render templates
		helmTemplateCmd := exec.Command("helm", "template",
			"-n", "org-giantswarm",
			"hello",
			".",
			"--values", filepath.Join(chartDir, "ci", testHelmValues),
			"--set", "providerIntegration.useReleases=false")
		helmTemplateCmd.Dir = chartDir

		// Create a temporary manifests output file
		manifestsFile, err := os.CreateTemp("", "cluster-manifests-*.yaml")
		Expect(err).NotTo(HaveOccurred())

		// Set the command output to the temporary file
		helmTemplateCmd.Stdout = manifestsFile

		// And capture errors in a buffer
		var helmTemplateStderrBuf bytes.Buffer
		helmTemplateCmd.Stderr = &helmTemplateStderrBuf

		// Finally run command to render templates
		err = helmTemplateCmd.Run()
		Expect(helmTemplateStderrBuf.Len()).To(BeZero(), helmTemplateStderrBuf.String())
		Expect(err).NotTo(HaveOccurred())

		// Now get containerd config
		yqCmd := exec.Command("yq", "select(.kind==\"Secret\") | select (.metadata.name | contains(\"containerd\")) | .data[\"config.toml\"]", manifestsFile.Name())
		var yqStdoutBuf bytes.Buffer
		var yqStderrBuf bytes.Buffer
		yqCmd.Stdout = &yqStdoutBuf
		yqCmd.Stderr = &yqStderrBuf

		err = yqCmd.Run()
		Expect(yqStderrBuf.Len()).To(BeZero(), yqStderrBuf.String())
		Expect(err).NotTo(HaveOccurred())

		// Get containerd config
		decodedBytes, err := base64.StdEncoding.DecodeString(yqStdoutBuf.String())
		Expect(err).NotTo(HaveOccurred())
		renderedContainerdConfig = strings.TrimSpace(string(decodedBytes))

		err = os.Remove(manifestsFile.Name())
		Expect(err).NotTo(HaveOccurred())
	})

	Context("when only required and default Helm values are used", func() {
		BeforeEach(func() {
			testHelmValues = "test-required-values.yaml"
		})

		It("renders expected containerd config with default MC zot endpoints", func() {
			expectedContainerdZotMcConfig = strings.TrimSpace(expectedContainerdZotMcConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedContainerdZotMcConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedContainerdZotMcConfig, renderedContainerdConfig))
		})
	})

	Context("when MC zot is enabled", func() {
		BeforeEach(func() {
			testHelmValues = "test-zot-mc-values.yaml"
		})

		It("renders expected containerd config with MC zot endpoints", func() {
			expectedContainerdZotMcConfig = strings.TrimSpace(expectedContainerdZotMcConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedContainerdZotMcConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedContainerdZotMcConfig, renderedContainerdConfig))
		})
	})

	Context("when local zot is enabled", func() {
		BeforeEach(func() {
			testHelmValues = "test-zot-local-values.yaml"
		})

		It("renders expected containerd config with local zot endpoints", func() {
			expectedContainerdZotLocalConfig = strings.TrimSpace(expectedContainerdZotLocalConfig)
			Expect(renderedContainerdConfig).To(Equal(expectedContainerdZotLocalConfig), fmt.Sprintf("expected:\n>>>%s<<<\n, got:\n>>>%s<<<", expectedContainerdZotLocalConfig, renderedContainerdConfig))
		})
	})
})
