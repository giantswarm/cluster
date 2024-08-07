.DEFAULT_GOAL:=help

##@ Build

TEST_CASE ?=
ifdef TEST_CASE
CI_FILE = "ci/test-$(TEST_CASE)-values.yaml"
else
CI_FILE ?= "ci/ci-values.yaml"
endif

RELEASE_VERSION ?=

.PHONY: template
template: ## Output the rendered Helm template
	$(eval CHART_DIR := "helm/cluster")
	$(eval HELM_RELEASE_NAME := $(shell yq .global.metadata.name ${CHART_DIR}/${CI_FILE}))
ifdef RELEASE_VERSION
	@helm template --dry-run=server -n org-giantswarm ${HELM_RELEASE_NAME} ${CHART_DIR} \
		--values ${CHART_DIR}/${CI_FILE} \
		--set global.release.version="${RELEASE_VERSION}" \
		--debug
else
	@helm template --dry-run=server -n org-giantswarm ${HELM_RELEASE_NAME} ${CHART_DIR} \
	--values ${CHART_DIR}/${CI_FILE} \
	--set providerIntegration.useReleases=false \
	--debug
endif

.PHONY: generate
generate: normalize-schema validate-schema generate-docs generate-values

.PHONY: ginkgo
ginkgo:
	@cd helm/cluster/tests && \
		go install github.com/onsi/ginkgo/v2/ginkgo && \
    	go get github.com/onsi/gomega/...

.PHONY: test
test: ginkgo
	@cd helm/cluster/tests && \
		ginkgo -v ./...
