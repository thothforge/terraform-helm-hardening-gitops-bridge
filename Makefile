# Terraform Hardening GitOps Bridge Module Makefile

.PHONY: help init validate format lint docs test clean examples

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Variables
TERRAFORM_VERSION := 1.0
AWS_REGION := us-west-2
EXAMPLE_DIR := examples

help: ## Display this help message
	@echo "$(BLUE)Terraform Hardening GitOps Bridge Module$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	terraform init

validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	terraform validate
	@echo "$(GREEN)✓ Terraform configuration is valid$(NC)"

format: ## Format Terraform code
	@echo "$(BLUE)Formatting Terraform code...$(NC)"
	terraform fmt -recursive
	@echo "$(GREEN)✓ Terraform code formatted$(NC)"

format-check: ## Check if Terraform code is formatted
	@echo "$(BLUE)Checking Terraform code formatting...$(NC)"
	@if terraform fmt -check -recursive; then \
		echo "$(GREEN)✓ Terraform code is properly formatted$(NC)"; \
	else \
		echo "$(RED)✗ Terraform code needs formatting$(NC)"; \
		exit 1; \
	fi

lint: ## Run Terraform linting
	@echo "$(BLUE)Running Terraform linting...$(NC)"
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
		echo "$(GREEN)✓ Terraform linting completed$(NC)"; \
	else \
		echo "$(YELLOW)⚠ tflint not installed, skipping linting$(NC)"; \
	fi

docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README.md .; \
		echo "$(GREEN)✓ Documentation generated$(NC)"; \
	else \
		echo "$(RED)✗ terraform-docs not installed$(NC)"; \
		echo "Install with: brew install terraform-docs"; \
		exit 1; \
	fi

pre-commit: ## Run pre-commit hooks
	@echo "$(BLUE)Running pre-commit hooks...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
		echo "$(GREEN)✓ Pre-commit hooks completed$(NC)"; \
	else \
		echo "$(RED)✗ pre-commit not installed$(NC)"; \
		echo "Install with: pip install pre-commit"; \
		exit 1; \
	fi

install-hooks: ## Install pre-commit hooks
	@echo "$(BLUE)Installing pre-commit hooks...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		echo "$(GREEN)✓ Pre-commit hooks installed$(NC)"; \
	else \
		echo "$(RED)✗ pre-commit not installed$(NC)"; \
		echo "Install with: pip install pre-commit"; \
		exit 1; \
	fi

test: validate format-check lint ## Run all tests
	@echo "$(GREEN)✓ All tests passed$(NC)"

test-examples: ## Test all examples
	@echo "$(BLUE)Testing examples...$(NC)"
	@for example in $(shell find $(EXAMPLE_DIR) -mindepth 1 -maxdepth 1 -type d); do \
		echo "$(BLUE)Testing $$example...$(NC)"; \
		cd $$example && terraform init && terraform validate && terraform plan; \
		if [ $$? -eq 0 ]; then \
			echo "$(GREEN)✓ $$example passed$(NC)"; \
		else \
			echo "$(RED)✗ $$example failed$(NC)"; \
			exit 1; \
		fi; \
		cd - > /dev/null; \
	done
	@echo "$(GREEN)✓ All examples tested successfully$(NC)"

plan-simple: ## Plan the simple example
	@echo "$(BLUE)Planning simple example...$(NC)"
	@cd $(EXAMPLE_DIR)/simple && terraform init && terraform plan

plan-complete: ## Plan the complete example
	@echo "$(BLUE)Planning complete example...$(NC)"
	@cd $(EXAMPLE_DIR)/complete && terraform init && terraform plan

apply-simple: ## Apply the simple example
	@echo "$(BLUE)Applying simple example...$(NC)"
	@cd $(EXAMPLE_DIR)/simple && terraform init && terraform apply

apply-complete: ## Apply the complete example
	@echo "$(BLUE)Applying complete example...$(NC)"
	@cd $(EXAMPLE_DIR)/complete && terraform init && terraform apply

destroy-simple: ## Destroy the simple example
	@echo "$(BLUE)Destroying simple example...$(NC)"
	@cd $(EXAMPLE_DIR)/simple && terraform destroy

destroy-complete: ## Destroy the complete example
	@echo "$(BLUE)Destroying complete example...$(NC)"
	@cd $(EXAMPLE_DIR)/complete && terraform destroy

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	find . -type f -name "*.tfplan" -delete
	find . -type f -name "*.tfstate*" -delete
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

security-scan: ## Run security scanning
	@echo "$(BLUE)Running security scan...$(NC)"
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d . --framework terraform; \
		echo "$(GREEN)✓ Security scan completed$(NC)"; \
	else \
		echo "$(YELLOW)⚠ checkov not installed, skipping security scan$(NC)"; \
		echo "Install with: pip install checkov"; \
	fi

cost-estimate: ## Estimate costs using Infracost
	@echo "$(BLUE)Estimating costs...$(NC)"
	@if command -v infracost >/dev/null 2>&1; then \
		cd $(EXAMPLE_DIR)/complete && infracost breakdown --path .; \
		echo "$(GREEN)✓ Cost estimation completed$(NC)"; \
	else \
		echo "$(YELLOW)⚠ infracost not installed, skipping cost estimation$(NC)"; \
		echo "Install from: https://www.infracost.io/docs/#quick-start"; \
	fi

check-tools: ## Check if required tools are installed
	@echo "$(BLUE)Checking required tools...$(NC)"
	@echo -n "Terraform: "
	@if command -v terraform >/dev/null 2>&1; then \
		echo "$(GREEN)✓ $(shell terraform version | head -n1)$(NC)"; \
	else \
		echo "$(RED)✗ Not installed$(NC)"; \
	fi
	@echo -n "AWS CLI: "
	@if command -v aws >/dev/null 2>&1; then \
		echo "$(GREEN)✓ $(shell aws --version)$(NC)"; \
	else \
		echo "$(RED)✗ Not installed$(NC)"; \
	fi
	@echo -n "kubectl: "
	@if command -v kubectl >/dev/null 2>&1; then \
		echo "$(GREEN)✓ $(shell kubectl version --client --short 2>/dev/null)$(NC)"; \
	else \
		echo "$(RED)✗ Not installed$(NC)"; \
	fi
	@echo -n "terraform-docs: "
	@if command -v terraform-docs >/dev/null 2>&1; then \
		echo "$(GREEN)✓ $(shell terraform-docs version)$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Not installed$(NC)"; \
	fi
	@echo -n "tflint: "
	@if command -v tflint >/dev/null 2>&1; then \
		echo "$(GREEN)✓ $(shell tflint --version)$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Not installed$(NC)"; \
	fi
	@echo -n "pre-commit: "
	@if command -v pre-commit >/dev/null 2>&1; then \
		echo "$(GREEN)✓ $(shell pre-commit --version)$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Not installed$(NC)"; \
	fi

install-tools: ## Install development tools (macOS)
	@echo "$(BLUE)Installing development tools...$(NC)"
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		echo "Installing tools via Homebrew..."; \
		brew install terraform terraform-docs tflint pre-commit; \
		pip install checkov; \
		echo "$(GREEN)✓ Tools installed$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Auto-installation only supported on macOS$(NC)"; \
		echo "Please install tools manually:"; \
		echo "  - Terraform: https://www.terraform.io/downloads"; \
		echo "  - terraform-docs: https://terraform-docs.io/user-guide/installation/"; \
		echo "  - tflint: https://github.com/terraform-linters/tflint"; \
		echo "  - pre-commit: pip install pre-commit"; \
		echo "  - checkov: pip install checkov"; \
	fi

ci: format-check validate lint test ## Run CI pipeline
	@echo "$(GREEN)✓ CI pipeline completed successfully$(NC)"

release-check: ## Check if ready for release
	@echo "$(BLUE)Checking release readiness...$(NC)"
	@$(MAKE) ci
	@$(MAKE) docs
	@$(MAKE) test-examples
	@echo "$(GREEN)✓ Ready for release$(NC)"

version: ## Show version information
	@echo "$(BLUE)Version Information$(NC)"
	@echo "$(BLUE)==================$(NC)"
	@echo "Module: Terraform Hardening GitOps Bridge"
	@echo "Version: 1.0.0"
	@echo "Terraform: $(shell terraform version | head -n1)"
	@echo "Git: $(shell git describe --tags --always --dirty 2>/dev/null || echo 'No git info')"

# Development workflow targets
dev-setup: check-tools install-hooks ## Set up development environment
	@echo "$(GREEN)✓ Development environment set up$(NC)"

dev-test: format validate lint ## Quick development test
	@echo "$(GREEN)✓ Development tests passed$(NC)"

dev-docs: docs ## Generate and preview documentation
	@echo "$(GREEN)✓ Documentation updated$(NC)"

# Example-specific targets
simple-workflow: ## Complete workflow for simple example
	@echo "$(BLUE)Running simple example workflow...$(NC)"
	@cd $(EXAMPLE_DIR)/simple && \
		terraform init && \
		terraform validate && \
		terraform plan -out=tfplan && \
		echo "$(GREEN)✓ Simple example ready for apply$(NC)"

complete-workflow: ## Complete workflow for complete example
	@echo "$(BLUE)Running complete example workflow...$(NC)"
	@cd $(EXAMPLE_DIR)/complete && \
		terraform init && \
		terraform validate && \
		terraform plan -out=tfplan && \
		echo "$(GREEN)✓ Complete example ready for apply$(NC)"
