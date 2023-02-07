.PHONY: identity
identity:
	aws-vault exec mt-playground -- aws sts get-caller-identity

.PHONY: init
init:
	aws-vault exec mt-playground -- terraform init -backend-config=secret.tfvars

.PHONY: plan
plan:
	aws-vault exec mt-playground -- terraform plan

.PHONY: apply
apply:
	aws-vault exec mt-playground -- terraform apply

.PHONY: destroy
destroy:
	aws-vault exec mt-playground -- terraform destroy

.PHONY: build
build:
	docker build --tag devops:latest .

.PHONY: run
run:
	docker run devops:latest