.PHONY: plan
plan:
	echo hello world

.PHONY: identity
identity:
	aws-vault exec mt-playground -- aws sts get-caller-identity

.PHONY: plan
identity:
	aws-vault exec mt-playground -- terraform plan

.PHONY: subshell
subshell:
	aws-vault exec mt-playground