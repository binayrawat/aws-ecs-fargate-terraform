IMAGE ?= ecs-fargate-demo:local
TF_DIRS := terraform/bootstrap terraform/environments/dev

.PHONY: help test run docker-build docker-run fmt validate lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  %-14s %s\n", $$1, $$2}'

test: ## Vet and run Go tests with the race detector
	cd app && go vet ./... && go test -race -cover ./...

run: ## Run the service locally on :8080
	cd app && go run .

docker-build: ## Build the container image
	docker build --build-arg VERSION=$$(git rev-parse --short HEAD 2>/dev/null || echo dev) -t $(IMAGE) app

docker-run: ## Run the container image on :8080
	docker run --rm -p 8080:8080 --read-only $(IMAGE)

fmt: ## Format Terraform code
	terraform fmt -recursive terraform

validate: ## Validate every Terraform stack (no AWS credentials needed)
	@for d in $(TF_DIRS); do \
		echo "== $$d"; \
		terraform -chdir=$$d init -backend=false -input=false >/dev/null && terraform -chdir=$$d validate || exit 1; \
	done

lint: ## Run tflint and checkov (requires both installed)
	tflint --init && tflint --recursive --config "$(CURDIR)/.tflint.hcl"
	checkov --config-file .checkov.yaml -d .
