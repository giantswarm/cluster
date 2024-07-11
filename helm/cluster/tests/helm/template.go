package helm

import (
	"bytes"
	"os/exec"
	"path/filepath"
	"runtime"

	. "github.com/onsi/gomega"
)

// Template runs `helm template` for cluster chart.
//
// The chart is templated with the specified Helm values file, namespace and Helm release name. You
// can also use otherArgs to pass any other argument that `helm template` command accepts.
func Template(chartDir, valuesFile, namespace, releaseName string, otherArgs ...string) string {
	// Collect all arguments into a slice.
	args := []string{
		"template",
		"-n", namespace,
		releaseName,
		".",
		"--values", filepath.Join(chartDir, "ci", valuesFile),
	}
	args = append(args, otherArgs...)

	// Create `helm template` command (we're still not running it here) and the directory in which
	// the command will be executed.
	cmd := exec.Command("helm", args...)
	cmd.Dir = chartDir

	// Set output buffers where we will write command's stdout and stderr.
	var stdoutBuf bytes.Buffer
	var stderrBuf bytes.Buffer
	cmd.Stdout = &stdoutBuf
	cmd.Stderr = &stderrBuf

	// Now run `helm template` command and capture the output.
	err := cmd.Run()

	// Expect that there were no errors in stderr and that command has finished successfully.
	Expect(stderrBuf.Len()).To(BeZero(), stderrBuf.String())
	Expect(err).NotTo(HaveOccurred())

	return stdoutBuf.String()
}

// GetClusterChartDir returns cluster chart dir.
//
// Notice that this function returns the correct cluster chart directory only when it's called from
// a file in cluster chart tests (github.com/giantswarm/cluster/helm/cluster/tests module).
func GetClusterChartDir() string {
	// Get cluster chart root directory where we will run `helm template` command.
	_, currentFilePath, _, ok := runtime.Caller(0)
	Expect(ok).To(BeTrue())
	currentDir := filepath.Dir(currentFilePath)
	testsModuleDir := filepath.Dir(currentDir)
	chartDir := filepath.Dir(testsModuleDir)

	return chartDir
}
