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
	aws-vault exec mt-playground -- aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 261219435789.dkr.ecr.eu-west-2.amazonaws.com
	docker build -t mt-devops .
	docker tag mt-devops:latest 261219435789.dkr.ecr.eu-west-2.amazonaws.com/mt-devops:latest
	docker push 261219435789.dkr.ecr.eu-west-2.amazonaws.com/mt-devops:latest

.PHONY: run-local
run-local:
	docker build -t local-devops:latest .
	docker run -p 80:80 local-devops:latest