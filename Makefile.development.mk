.DEFAULT_GOAL:=help

##@ Generate

ensure-schema-gen:
	@helm schema-gen --help &>/dev/null || helm plugin install https://github.com/mihaisee/helm-schema-gen.git

.PHONY: generate-schema
generate-schema: ensure-schema-gen ## Generate the values.schema.json file from the values.yaml
	@cd helm/cluster && helm schema-gen values.yaml > values.schema.json

##@ Build

.PHONY: template
template: ## Output the rendered Helm template
	@cd helm/cluster && \
		sed -i 's/version: \[/version: 1 #\[/' Chart.yaml && \
		helm template -f test/minimal-values.yaml . && \
		sed -i 's/version: 1 #\[/version: \[/' Chart.yaml
