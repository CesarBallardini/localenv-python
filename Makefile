.DEFAULT_GOAL := help

.PHONY: help install lint format types test test-bdd test-integration test-e2e \
        coverage security secrets licenses docs docs-serve release-next \
        precommit clean

help: ## Show this list of available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

install: ## Sync the environment (from the committed lockfile) and install the git hooks
	uv sync --all-groups --frozen
	uv run --frozen pre-commit install

lint: ## Check formatting and lint rules without modifying files
	uv run --frozen ruff check .
	uv run --frozen ruff format --check .

format: ## Auto-fix formatting and lint issues
	uv run --frozen ruff format .
	uv run --frozen ruff check --fix .

types: ## Run both type checkers (pyright + pyrefly)
	uv run --frozen pyright
	uv run --frozen pyrefly check

test: ## Run the test suite (unit + integration + acceptance; e2e excluded by default)
	uv run --frozen pytest

test-bdd: ## Run only the BDD/acceptance tests (pytest-bdd)
	uv run --frozen pytest -m bdd

test-integration: ## Run only the integration tests (need a real DB/service)
	uv run --frozen pytest -m integration

test-e2e: ## Run end-to-end tests (requires: uv run --frozen playwright install)
	uv run --frozen pytest -m e2e

coverage: ## Run the test suite with coverage and enforce the floor from .coveragerc
	uv run --frozen pytest --cov=task_list --cov-config=.coveragerc --cov-report=term-missing --cov-report=html

security: ## Run every security scan (SAST + CVEs + secrets + licenses)
	uv run --frozen bandit -c bandit.yaml -r src
	uv run --frozen pip-audit --skip-editable
	osv-scanner --lockfile=./uv.lock
	$(MAKE) secrets
	$(MAKE) licenses

secrets: ## Scan the working tree for committed secrets (needs gitleaks on PATH)
	gitleaks dir . --redact --verbose

licenses: ## Report dependency licenses and gate the ones that actually ship
	uv run --frozen pip-licenses --format=markdown
	@runtime=$$(uv export --frozen --no-dev --no-emit-project --no-hashes --format requirements.txt \
	   | sed -e 's/[[:space:]]*[;#].*$$//' -e 's/[=<>!~].*$$//' -e '/^$$/d' \
	   | paste -sd' ' -); \
	if [ -z "$$runtime" ]; then \
	  echo "No runtime dependencies to check; nothing is distributed yet."; \
	else \
	  echo "Checking: $$runtime"; \
	  uv run --frozen pip-licenses --packages $$runtime \
	    --fail-on="GNU General Public License (GPL);GNU General Public License v2 or later (GPLv2+);GNU General Public License v3 (GPLv3);GNU Affero General Public License v3 or later (AGPLv3+)"; \
	fi

docs: ## Build the documentation site (--strict: warnings are failures)
	uv run --frozen mkdocs build --strict

docs-serve: ## Serve the documentation locally with live reload
	uv run --frozen mkdocs serve

release-next: ## Show the version the next release would get (creates no tag)
	uv run --frozen cz bump --get-next --yes

precommit: ## Run all pre-commit hooks against every file
	uv run --frozen pre-commit run --all-files

clean: ## Remove build, cache and coverage artifacts
	rm -rf site/ dist/ build/ htmlcov/ .coverage coverage.xml \
	       .pytest_cache/ .ruff_cache/ .pyrefly_cache/
