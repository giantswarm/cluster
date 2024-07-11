package yq

import (
	"bytes"
	"os/exec"

	. "github.com/onsi/gomega"
)

// Run executes a `yq` command with the specified query for the specified input.
func Run(input, query string) string {
	// Create `yq` command (we're still not running it here).
	cmd := exec.Command("yq", query)

	// Create a buffer to provide the input to the command.
	cmd.Stdin = bytes.NewBufferString(input)

	// Set output buffers where we will write command's stdout and stderr.
	var stdoutBuf bytes.Buffer
	var stderrBuf bytes.Buffer
	cmd.Stdout = &stdoutBuf
	cmd.Stderr = &stderrBuf

	err := cmd.Run()
	Expect(stderrBuf.Len()).To(BeZero(), stderrBuf.String())
	Expect(err).NotTo(HaveOccurred())

	return stdoutBuf.String()
}
