# Alpha Intelligence Hub - Unified Build Commands
# Usage: make <target>

.PHONY: help init build up down test lint clean

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Setup ---
init: ## Run full migration (merges all repos)
	chmod +x init-hub.sh
	./init-hub.sh

setup: ## Install Python dependencies
	pip install -r requirements.txt
	pip install -r requirements-dev.txt 2>/dev/null || true

# --- Docker ---
build: ## Build all Docker services
	docker compose build

up: ## Start all services
	docker compose up -d
	echo "Services running:"
	echo "  Gateway:    http://localhost:18789"
	echo "  Treasury:   http://localhost:8001"
	echo "  WorldTribe: http://localhost:8002"
	echo "  SafetyKern: http://localhost:8003"
	echo "  Aethel:     http://localhost:8004"
	echo "  ALEXARAC:   http://localhost:3000"
	echo "  Dashboard:  http://localhost:3001"

down: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose down
	docker compose up -d

logs: ## Tail all service logs
	docker compose logs -f

# --- Testing ---
test: ## Run all tests
	@echo "=== Safety Kernel ==="
	cd core/safety-kernel && python -m pytest test_sk.py test_tamper.py -v
	@echo "=== Platform ==="
	python -m pytest tests/ -v
	@echo "=== Aethel Validator ==="
	cd core/undermoon/aethel-grid && cargo test --release
	@echo "=== WorldTribe ==="
	cd blockchain/world-tribe && python scripts/test_worldtribe.py

test-python: ## Run Python tests only
	cd core/safety-kernel && python -m pytest test_sk.py test_tamper.py -v
	python -m pytest tests/ -v

test-rust: ## Run Rust tests only
	cd core/undermoon/aethel-grid && cargo test --release

test-solidity: ## Run Solidity tests only
	cd blockchain/world-tribe && python scripts/test_worldtribe.py

# --- Code Quality ---
lint: ## Lint all Python code
	python -m flake8 platform/src/ core/safety-kernel/
	python -m mypy platform/src/ --ignore-missing-imports

format: ## Auto-format Python code
	python -m black platform/src/ core/safety-kernel/ tests/
	python -m isort platform/src/ core/safety-kernel/ tests/

# --- Submodules ---
sync-openclaw: ## Update OpenClaw submodule to latest
	git submodule update --remote ai/openclaw
	echo "OpenClaw updated to latest commit"

# --- Cleanup ---
clean: ## Remove build artifacts and caches
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete 2>/dev/null || true
	rm -rf .pytest_cache .mypy_cache
	cd core/undermoon/aethel-grid && cargo clean 2>/dev/null || true
	docker compose down --rmi local --volumes 2>/dev/null || true
