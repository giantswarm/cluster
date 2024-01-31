.DEFAULT_GOAL:=help

##@ Generate

ensure-schema-gen:
	@helm schema-gen --help >/dev/null || helm plugin install https://github.com/mihaisee/helm-schema-gen.git

##@ Build

TEST_CASE ?=
ifdef TEST_CASE
CI_FILE = "ci/test-$(TEST_CASE)-values.yaml"
else
CI_FILE ?= "ci/ci-values.yaml"
endif

.PHONY: template
template: ## Output the rendered Helm template
	$(eval CHART_DIR := "helm/cluster")
	$(eval HELM_RELEASE_NAME := $(shell yq .global.metadata.name ${CHART_DIR}/${CI_FILE}))
	@cd ${CHART_DIR} && \
		helm template -f ${CI_FILE} --debug ${HELM_RELEASE_NAME} .

.PHONY: generate
generate: normalize-schema validate-schema generate-docs generate-values
