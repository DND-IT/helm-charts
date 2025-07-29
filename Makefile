# Multi-Chart Repository Makefile

.PHONY: help lint test template install uninstall package clean docs list-charts

# Default target
help: ## Show this help message
	@echo "Multi-Chart Repository Makefile"
	@echo "Usage: make <target> CHART=<chart-name>"
	@echo ""
	@echo "Available charts:"
	@$(MAKE) list-charts
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $1, $2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make lint CHART=generic-app"
	@echo "  make install CHART=my-service RELEASE=prod-service"
	@echo "  make template CHART=generic-app VALUES=custom-values.yaml"

# Variables
CHART ?=
RELEASE ?= test-release
NAMESPACE ?= default
VALUES ?= values.yaml
EXAMPLE_VALUES ?= values-example.yaml
CHART_DIR = charts

# Auto-detect charts if CHART is not provided
CHARTS_AVAILABLE := $(shell find $(CHART_DIR) -maxdepth 1 -type d -not -path $(CHART_DIR) -exec basename {} \; 2>/dev/null || find . -maxdepth 1 -name "Chart.yaml" -exec dirname {} \; | sed 's|^\./||' | head -1)

# Set chart path based on structure
# Only check for CHART if we're not running a target that doesn't need it
TARGETS_WITHOUT_CHART := help list-charts lint-all test-all template-all package-all docs-all \
                        integration-test-all security-scan-all clean clean-releases \
                        repo-lint repo-test repo-package quality-all prepare-release \
                        kind-create kind-delete kind-test-all dependency-update-all \
                        check-tools version-all ci-setup ci-test help-chart kubeconform-all

ifeq ($(filter $(MAKECMDGOALS),$(TARGETS_WITHOUT_CHART)),)
    ifeq ($(CHART),)
        $(error CHART is required. Use: make <target> CHART=<chart-name>. Available charts: $(CHARTS_AVAILABLE))
    endif
endif

# Determine if we're in a multi-chart repo or single chart repo
ifneq ($(wildcard $(CHART_DIR)/$(CHART)),)
    CHART_PATH := $(CHART_DIR)/$(CHART)
else ifneq ($(wildcard $(CHART)),)
    CHART_PATH := $(CHART)
else ifneq ($(wildcard Chart.yaml),)
    CHART_PATH := .
else
    $(error Chart '$(CHART)' not found. Available charts: $(CHARTS_AVAILABLE))
endif

# Construct values file paths
VALUES_FILE := $(CHART_PATH)/$(VALUES)
EXAMPLE_VALUES_FILE := $(CHART_PATH)/$(EXAMPLE_VALUES)

# Chart discovery and listing
list-charts: ## List all available charts
	@echo "Available charts:"
	@if [ -d "$(CHART_DIR)" ]; then \
		find $(CHART_DIR) -maxdepth 1 -type d -not -path $(CHART_DIR) -exec basename {} \; | sort; \
	elif [ -f "Chart.yaml" ]; then \
		echo "$(shell basename $(PWD)) (single chart repository)"; \
	else \
		echo "No charts found"; \
	fi

validate-chart: ## Validate that chart exists and is properly configured
	@echo "Validating chart: $(CHART)"
	@if [ ! -d "$(CHART_PATH)" ]; then \
		echo "Error: Chart directory '$(CHART_PATH)' does not exist"; \
		echo "Available charts: $(CHARTS_AVAILABLE)"; \
		exit 1; \
	fi
	@if [ ! -f "$(CHART_PATH)/Chart.yaml" ]; then \
		echo "Error: Chart.yaml not found in '$(CHART_PATH)'"; \
		exit 1; \
	fi
	@echo "Chart '$(CHART)' found at '$(CHART_PATH)'"

# Linting
lint: validate-chart ## Run chart linting for specified chart
	@echo "Running helm lint on $(CHART)..."
	helm lint $(CHART_PATH)
	@if command -v ct >/dev/null 2>&1; then \
		echo "Running chart-testing lint on $(CHART)..."; \
		ct lint --charts $(CHART_PATH); \
	else \
		echo "chart-testing not available, skipping ct lint"; \
	fi

lint-all: ## Run linting on all charts
	@echo "Running lint on all charts..."
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Linting $chart..."; \
		$(MAKE) lint CHART=$chart || exit 1; \
	done

# Testing
test: validate-chart ## Run unit tests for specified chart
	@echo "Running helm unittest on $(CHART)..."
	@if [ -d "$(CHART_PATH)/tests" ]; then \
		helm unittest $(CHART_PATH); \
	else \
		echo "No tests directory found for $(CHART), skipping unit tests"; \
	fi

test-all: ## Run tests on all charts
	@echo "Running tests on all charts..."
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Testing $chart..."; \
		$(MAKE) test CHART=$chart || exit 1; \
	done

test-all: lint-all test-all ## Run all tests on all charts

# Template generation
template: validate-chart ## Generate templates for specified chart with default values
	@echo "Generating templates for $(CHART) with default values..."
	helm template $(RELEASE) $(CHART_PATH) --debug

template-example: validate-chart ## Generate templates for specified chart with example values
	@echo "Generating templates for $(CHART) with example values..."
	@if [ -f "$(EXAMPLE_VALUES_FILE)" ]; then \
		helm template $(RELEASE) $(CHART_PATH) -f $(EXAMPLE_VALUES_FILE) --debug; \
	else \
		echo "Example values file not found at $(EXAMPLE_VALUES_FILE)"; \
		echo "Using default values instead..."; \
		helm template $(RELEASE) $(CHART_PATH) --debug; \
	fi

template-custom: validate-chart ## Generate templates with custom values file
	@echo "Generating templates for $(CHART) with custom values..."
	@if [ -f "$(VALUES_FILE)" ]; then \
		helm template $(RELEASE) $(CHART_PATH) -f $(VALUES_FILE) --debug; \
	else \
		echo "Values file not found at $(VALUES_FILE)"; \
		exit 1; \
	fi

template-output: validate-chart ## Generate templates and save to file
	@echo "Generating templates for $(CHART) to output file..."
	@mkdir -p output
	@if [ -f "$(EXAMPLE_VALUES_FILE)" ]; then \
		helm template $(RELEASE) $(CHART_PATH) -f $(EXAMPLE_VALUES_FILE) > output/$(CHART)-manifests.yaml; \
		echo "Templates saved to output/$(CHART)-manifests.yaml"; \
	else \
		helm template $(RELEASE) $(CHART_PATH) > output/$(CHART)-manifests.yaml; \
		echo "Templates saved to output/$(CHART)-manifests.yaml (using default values)"; \
	fi

template-all: ## Generate templates for all charts
	@echo "Generating templates for all charts..."
	@mkdir -p output
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Generating templates for $chart..."; \
		$(MAKE) template-output CHART=$chart RELEASE=$chart-test || exit 1; \
	done

# Installation
install: validate-chart ## Install specified chart with default values
	@echo "Installing chart $(CHART) as release $(RELEASE)..."
	@if [ -f "$(VALUES_FILE)" ] && [ "$(VALUES)" != "values.yaml" ]; then \
		helm install $(RELEASE) $(CHART_PATH) -f $(VALUES_FILE) --namespace $(NAMESPACE) --create-namespace --wait; \
	else \
		helm install $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --wait; \
	fi

install-example: validate-chart ## Install specified chart with example values
	@echo "Installing chart $(CHART) with example values..."
	@if [ -f "$(EXAMPLE_VALUES_FILE)" ]; then \
		helm install $(RELEASE) $(CHART_PATH) -f $(EXAMPLE_VALUES_FILE) --namespace $(NAMESPACE) --create-namespace --wait; \
	else \
		echo "Example values file not found, installing with default values..."; \
		helm install $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --wait; \
	fi

upgrade: validate-chart ## Upgrade existing installation
	@echo "Upgrading chart $(CHART) release $(RELEASE)..."
	@if [ -f "$(VALUES_FILE)" ] && [ "$(VALUES)" != "values.yaml" ]; then \
		helm upgrade $(RELEASE) $(CHART_PATH) -f $(VALUES_FILE) --namespace $(NAMESPACE) --wait; \
	else \
		helm upgrade $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --wait; \
	fi

uninstall: ## Uninstall specified release
	@echo "Uninstalling release $(RELEASE)..."
	helm uninstall $(RELEASE) --namespace $(NAMESPACE)

# Packaging
package: validate-chart ## Package specified chart
	@echo "Packaging chart $(CHART)..."
	@mkdir -p packages
	helm package $(CHART_PATH) --destination packages/
	@echo "Chart $(CHART) packaged in packages/"

package-all: ## Package all charts
	@echo "Packaging all charts..."
	@mkdir -p packages
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Packaging $chart..."; \
		helm package $(CHART_DIR)/$chart --destination packages/ 2>/dev/null || helm package $chart --destination packages/ || exit 1; \
	done
	@echo "All charts packaged in packages/"

# Documentation
docs: validate-chart ## Generate documentation for specified chart
	@echo "Generating documentation for $(CHART)..."
	@if command -v helm-docs >/dev/null 2>&1; then \
		helm-docs --chart-search-root=$(CHART_PATH) --template-files=README.md.gotmpl; \
	else \
		echo "helm-docs not available. Install it with: go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest"; \
	fi

docs-all: ## Generate documentation for all charts
	@echo "Generating documentation for all charts..."
	@if command -v helm-docs >/dev/null 2>&1; then \
		if [ -d "$(CHART_DIR)" ]; then \
			helm-docs --chart-search-root=$(CHART_DIR); \
		else \
			helm-docs --chart-search-root=.; \
		fi \
	else \
		echo "helm-docs not available. Install it with: go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest"; \
	fi

# Development
dev-install: validate-chart ## Install chart in development mode with auto-reload
	@echo "Installing chart $(CHART) in development mode..."
	helm install $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --wait --debug
	@echo "Chart installed. Use 'make dev-upgrade CHART=$(CHART) RELEASE=$(RELEASE)' to apply changes."

dev-upgrade: validate-chart ## Upgrade chart in development mode
	@echo "Upgrading chart $(CHART) in development mode..."
	helm upgrade $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --wait --debug --force

dev-reset: uninstall install ## Reset development environment

# Debugging
debug: validate-chart ## Debug chart installation (dry-run)
	@echo "Debugging chart $(CHART) installation..."
	helm install $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --dry-run --debug

debug-example: validate-chart ## Debug chart with example values (dry-run)
	@echo "Debugging chart $(CHART) with example values..."
	@if [ -f "$(EXAMPLE_VALUES_FILE)" ]; then \
		helm install $(RELEASE) $(CHART_PATH) -f $(EXAMPLE_VALUES_FILE) --namespace $(NAMESPACE) --create-namespace --dry-run --debug; \
	else \
		echo "Example values file not found, debugging with default values..."; \
		helm install $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --dry-run --debug; \
	fi

# Status and information
status: ## Show release status
	@echo "Checking release $(RELEASE) status..."
	helm status $(RELEASE) --namespace $(NAMESPACE)

get-values: ## Get current values for release
	@echo "Getting current values for release $(RELEASE)..."
	helm get values $(RELEASE) --namespace $(NAMESPACE)

get-manifest: ## Get current manifest for release
	@echo "Getting current manifest for release $(RELEASE)..."
	helm get manifest $(RELEASE) --namespace $(NAMESPACE)

list-releases: ## List all releases in namespace
	@echo "Listing all releases in namespace $(NAMESPACE)..."
	helm list --namespace $(NAMESPACE)

# Integration testing
integration-test: validate-chart ## Run integration tests for specified chart
	@echo "Running integration tests for $(CHART)..."
	@INTEGRATION_RELEASE="$(CHART)-integration-test" && \
	helm install $INTEGRATION_RELEASE $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --wait && \
	kubectl get all -n $(NAMESPACE) -l app.kubernetes.io/instance=$INTEGRATION_RELEASE && \
	echo "Waiting for pods to be ready..." && \
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=$INTEGRATION_RELEASE -n $(NAMESPACE) --timeout=300s && \
	echo "Integration test for $(CHART) passed!" && \
	helm uninstall $INTEGRATION_RELEASE --namespace $(NAMESPACE)

integration-test-all: ## Run integration tests for all charts
	@echo "Running integration tests for all charts..."
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Testing $chart..."; \
		$(MAKE) integration-test CHART=$chart NAMESPACE=$chart-test || exit 1; \
	done

# Validation with kubeconform
kubeconform: validate-chart ## Run kubeconform validation on specified chart
	@echo "Running kubeconform validation on $(CHART)..."
	@if command -v kubeconform >/dev/null 2>&1; then \
		for VALUES_FILE in $(CHART_PATH)/ci/*.yaml; do \
			if [ -f "$VALUES_FILE" ]; then \
				echo "Validating with $VALUES_FILE..."; \
				helm template $(CHART_PATH) --values "$VALUES_FILE" | kubeconform -strict -ignore-missing-schemas -kubernetes-version 1.32.0 || exit 1; \
			fi; \
		done; \
		echo "Kubeconform validation passed for $(CHART)"; \
	else \
		echo "kubeconform not available. Install it from: https://github.com/yannh/kubeconform"; \
		exit 1; \
	fi

kubeconform-all: ## Run kubeconform validation on all charts
	@echo "Running kubeconform validation on all charts..."
	@if ! command -v kubeconform >/dev/null 2>&1; then \
		echo "kubeconform not available. Install it from: https://github.com/yannh/kubeconform"; \
		exit 1; \
	fi
	@for chart in $(shell find $(CHART_DIR) -maxdepth 1 -type d -not -path $(CHART_DIR) -exec basename {} \; 2>/dev/null | sort); do \
		echo "Validating $$chart..."; \
		$(MAKE) kubeconform CHART=$$chart || exit 1; \
	done

# Security scanning
security-scan: validate-chart ## Run security scan on generated manifests for specified chart
	@echo "Running security scan for $(CHART)..."
	@mkdir -p tmp/security-scan
	@if [ -f "$(EXAMPLE_VALUES_FILE)" ]; then \
		helm template security-test $(CHART_PATH) -f $(EXAMPLE_VALUES_FILE) > tmp/security-scan/$(CHART)-manifests.yaml; \
	else \
		helm template security-test $(CHART_PATH) > tmp/security-scan/$(CHART)-manifests.yaml; \
	fi
	@if command -v trivy >/dev/null 2>&1; then \
		trivy config tmp/security-scan/$(CHART)-manifests.yaml; \
	else \
		echo "Trivy not available. Install it for security scanning."; \
		echo "Generated manifests saved to tmp/security-scan/$(CHART)-manifests.yaml for manual review."; \
	fi

security-scan-all: ## Run security scan on all charts
	@echo "Running security scan on all charts..."
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Scanning $chart..."; \
		$(MAKE) security-scan CHART=$chart || exit 1; \
	done

# Cleanup
clean: ## Clean up generated files
	@echo "Cleaning up generated files..."
	rm -rf packages/
	rm -rf output/
	rm -rf tmp/
	rm -f manifests.yaml
	@echo "Cleanup complete"

clean-releases: ## Clean up test releases in namespace
	@echo "Cleaning up test releases in namespace $(NAMESPACE)..."
	@helm list --namespace $(NAMESPACE) --short | grep -E "(test-|integration-test)" | xargs -r helm uninstall --namespace $(NAMESPACE)

# Repository management
repo-lint: lint-all ## Lint entire repository
	@echo "Repository linting complete"

repo-test: test-all ## Test entire repository
	@echo "Repository testing complete"

repo-package: package-all ## Package all charts in repository
	@echo "Repository packaging complete"

# Quality checks
quality: validate-chart lint test kubeconform security-scan ## Run all quality checks for specified chart
	@echo "Quality checks completed for $(CHART)"

quality-all: lint-all test-all kubeconform-all security-scan-all ## Run all quality checks for all charts
	@echo "Quality checks completed for all charts"

# Release preparation
prepare-release: clean repo-package ## Prepare repository for release
	@echo "Repository prepared for release"

prepare-chart-release: clean quality package ## Prepare specific chart for release
	@echo "Chart $(CHART) prepared for release"

# Local development with kind
kind-create: ## Create kind cluster for local development
	@echo "Creating kind cluster for development..."
	@if [ -f "kind-config.yaml" ]; then \
		kind create cluster --name charts-dev --config kind-config.yaml; \
	else \
		kind create cluster --name charts-dev; \
	fi

kind-delete: ## Delete kind cluster
	@echo "Deleting kind cluster..."
	kind delete cluster --name charts-dev

kind-install: validate-chart ## Install chart in kind cluster
	@echo "Installing chart $(CHART) in kind cluster..."
	helm install $(RELEASE) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --wait

kind-test-all: kind-create ## Create kind cluster and test all charts
	@echo "Testing all charts in kind cluster..."
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Testing $chart in kind..."; \
		$(MAKE) kind-install CHART=$chart RELEASE=$chart-kind-test NAMESPACE=$chart-test || exit 1; \
		$(MAKE) uninstall RELEASE=$chart-kind-test NAMESPACE=$chart-test || true; \
	done

# Chart dependency management
dependency-update: validate-chart ## Update chart dependencies
	@echo "Updating dependencies for $(CHART)..."
	@if [ -f "$(CHART_PATH)/Chart.lock" ]; then \
		helm dependency update $(CHART_PATH); \
	else \
		echo "No Chart.lock found for $(CHART), checking for dependencies..."; \
		if grep -q "^dependencies:" $(CHART_PATH)/Chart.yaml 2>/dev/null; then \
			helm dependency update $(CHART_PATH); \
		else \
			echo "No dependencies found for $(CHART)"; \
		fi \
	fi

dependency-update-all: ## Update dependencies for all charts
	@echo "Updating dependencies for all charts..."
	@for chart in $(CHARTS_AVAILABLE); do \
		echo "Updating dependencies for $chart..."; \
		$(MAKE) dependency-update CHART=$chart || exit 1; \
	done

# Utility targets
check-tools: ## Check if required tools are installed
	@echo "Checking required tools..."
	@command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed. Aborting." >&2; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Aborting." >&2; exit 1; }
	@echo "✅ helm: $(shell helm version --short)"
	@echo "✅ kubectl: $(shell kubectl version --client --short 2>/dev/null || echo 'installed')"
	@command -v ct >/dev/null 2>&1 && echo "✅ chart-testing: available" || echo "⚠️  chart-testing: not installed (recommended)"
	@command -v helm-docs >/dev/null 2>&1 && echo "✅ helm-docs: available" || echo "⚠️  helm-docs: not installed (recommended)"
	@command -v kubeconform >/dev/null 2>&1 && echo "✅ kubeconform: available" || echo "⚠️  kubeconform: not installed (recommended for validation)"
	@command -v trivy >/dev/null 2>&1 && echo "✅ trivy: available" || echo "⚠️  trivy: not installed (recommended for security scanning)"
	@command -v kind >/dev/null 2>&1 && echo "✅ kind: available" || echo "⚠️  kind: not installed (recommended for local testing)"

version: validate-chart ## Show chart version and app version
	@echo "Chart: $(CHART)"
	@echo "Chart version: $(helm show chart $(CHART_PATH) | grep '^version:' | cut -d' ' -f2)"
	@echo "App version: $(helm show chart $(CHART_PATH) | grep '^appVersion:' | cut -d' ' -f2)"

version-all: ## Show versions for all charts
	@echo "Chart versions:"
	@for chart in $(CHARTS_AVAILABLE); do \
		if [ -d "$(CHART_DIR)/$chart" ]; then \
			chart_path="$(CHART_DIR)/$chart"; \
		else \
			chart_path="$chart"; \
		fi; \
		version=$(helm show chart $chart_path | grep '^version:' | cut -d' ' -f2); \
		app_version=$(helm show chart $chart_path | grep '^appVersion:' | cut -d' ' -f2); \
		printf "  %-20s %s (app: %s)\n" "$chart" "$version" "$app_version"; \
	done

# CI/CD helpers
ci-setup: check-tools ## Setup CI environment
	@echo "Setting up CI environment..."
	@helm plugin list | grep -q unittest || helm plugin install https://github.com/helm-unittest/helm-unittest

ci-test: ci-setup lint-all test-all ## Run CI tests
	@echo "CI tests completed successfully"

# Help for chart-specific commands
help-chart: ## Show help for chart-specific commands
	@echo "Chart-specific commands (require CHART parameter):"
	@echo ""
	@echo "Basic Operations:"
	@echo "  make lint CHART=my-chart              # Lint specific chart"
	@echo "  make test CHART=my-chart              # Test specific chart"
	@echo "  make install CHART=my-chart          # Install chart"
	@echo "  make template CHART=my-chart         # Generate templates"
	@echo ""
	@echo "Development:"
	@echo "  make dev-install CHART=my-chart RELEASE=dev  # Install in dev mode"
	@echo "  make debug CHART=my-chart            # Dry-run installation"
	@echo ""
	@echo "Custom Values:"
	@echo "  make install CHART=my-chart VALUES=custom.yaml"
	@echo "  make template CHART=my-chart VALUES=staging.yaml"
	@echo ""
	@echo "Multiple Charts Operations:"
	@echo "  make lint-all                        # Lint all charts"
	@echo "  make test-all                        # Test all charts"
	@echo "  make package-all                     # Package all charts"

# Include custom targets if they exist
-include Makefile.local
