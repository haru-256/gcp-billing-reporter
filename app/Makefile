.DEFAULT_GOAL := help

.PHONY: lint
lint: ## Run Linter
	uv run ruff check .
	uv run mypy .

.PHONY: fmt
fmt: ## Run formatter
	uv run ruff check --fix .
	uv run ruff format .

.PHONY: test
test: ## Run tests
	uv run pytest .

.PHONY: lock
lock: ## Lock dependencies
	uv lock

.PHONY: install
install: ## Setup the project
	uv sync --all-groups

.PHONY: test-integration
test-integration: ## Run live CloudEvent smoke test
	RUN_LIVE_GCP_TESTS=1 uv run pytest tests/test_main.py -m live

.PHONY: run-server-local
run-server-local: ## Run functions-framework locally
	uv run functions-framework \
		--target=main \
		--signature-type=cloudevent \
		--port=9999

.PHONY: send-event-local
send-event-local: ## Send a Pub/Sub CloudEvent to the local functions-framework server
	curl -fsS -X POST "http://localhost:9999/" \
		-H "Content-Type: application/json" \
		-H "Ce-Id: local-test-1" \
		-H "Ce-Specversion: 1.0" \
		-H "Ce-Type: google.cloud.pubsub.topic.v1.messagePublished" \
		-H "Ce-Source: //pubsub.googleapis.com/projects/local-project/topics/local-topic" \
		-d '{"message":{"data":"e30=","messageId":"1"},"subscription":"local"}'

.PHONY: help
help: ## Show options
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
