# Copyright 2025 - Cowboy AI, LLC
# CIM-Start Makefile

.PHONY: help start stop restart status init-streams test-events clean logs monitor shell

# Default environment
ENV ?= dev
NATS_URL ?= nats://localhost:4222

help: ## Show this help message
	@echo "CIM-Start NATS JetStream Environment"
	@echo ""
	@echo "Usage: make [target] [ENV=dev|staging|prod]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

start: ## Start the NATS environment
	@echo "Starting CIM NATS environment..."
	docker-compose up -d
	@echo "Waiting for NATS to be ready..."
	@sleep 10
	@make status

stop: ## Stop the NATS environment  
	@echo "Stopping CIM NATS environment..."
	docker-compose down

restart: ## Restart the NATS environment
	@make stop
	@make start

status: ## Show service status
	@echo "=== Service Status ==="
	docker-compose ps
	@echo ""
	@echo "=== NATS Health Check ==="
	@curl -s http://localhost:8222/healthz && echo " ✓ NATS is healthy" || echo " ✗ NATS is not responding"
	@echo ""
	@echo "=== NATS Server Info ==="
	@curl -s http://localhost:8222/varz | jq -r '"Server: " + .server_name + " | Version: " + .version + " | Connections: " + (.connections|tostring)' 2>/dev/null || echo "Unable to get server info"

init-streams: ## Initialize NATS streams for domain events
	@echo "Initializing NATS streams for environment: $(ENV)"
	CIM_ENVIRONMENT=$(ENV) NATS_URL=$(NATS_URL) ./scripts/init-streams.sh
	@echo "Streams initialized successfully"

test-events: ## Test domain event publishing and consumption
	@echo "Testing domain events for environment: $(ENV)"
	CIM_ENVIRONMENT=$(ENV) NATS_URL=$(NATS_URL) ./scripts/test-domain-events.sh

clean: ## Clean up volumes and containers
	@echo "Cleaning up CIM NATS environment..."
	docker-compose down -v --remove-orphans
	docker volume prune -f

logs: ## Show logs from all services
	docker-compose logs -f

logs-nats: ## Show NATS server logs only
	docker-compose logs -f nats

monitor: ## Open monitoring dashboards
	@echo "Opening monitoring dashboards..."
	@echo "NATS Dashboard: http://localhost:8222"
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000 (admin/admin)"
	@which open >/dev/null 2>&1 && open http://localhost:8222 || echo "Open your browser to the URLs above"

shell: ## Get a shell in nats-box container
	docker-compose exec nats-box sh

# Stream management targets
list-streams: ## List all NATS streams
	docker-compose exec nats-box nats stream list

stream-info: ## Show information about a specific stream (make stream-info STREAM=DOMAIN_SALES_EVENTS)
	docker-compose exec nats-box nats stream info $(STREAM)

purge-stream: ## Purge a specific stream (make purge-stream STREAM=DOMAIN_SALES_EVENTS)
	docker-compose exec nats-box nats stream purge $(STREAM) --force

# Development targets
dev: ## Start development environment
	@make ENV=dev start
	@make ENV=dev init-streams
	@echo ""
	@echo "🚀 Development environment ready!"
	@echo "   NATS: nats://localhost:4222"
	@echo "   Monitor: http://localhost:8222"
	@echo "   Environment: dev"
	@echo ""
	@echo "Next steps:"
	@echo "   make test-events    # Test the setup"
	@echo "   make monitor        # Open dashboards"
	@echo "   make shell          # Get NATS CLI access"

staging: ## Start staging environment
	@make ENV=staging start
	@make ENV=staging init-streams

prod: ## Start production environment (use with caution)
	@make ENV=prod start
	@make ENV=prod init-streams

# Quick development commands
quick-test: ## Quick test with a simple event
	@echo "Publishing test event..."
	docker-compose exec nats-box nats pub "$(ENV).domain.test.aggregate.event.$$(date +%s)" '{"test": true, "timestamp": "'$$(date -Iseconds)'"}'
	@echo "Event published successfully"

watch-events: ## Watch all domain events in real-time
	docker-compose exec nats-box nats sub "$(ENV).domain.>"

watch-commands: ## Watch all commands in real-time  
	docker-compose exec nats-box nats sub "$(ENV).command.>"

# Backup and restore
backup: ## Backup all streams to ./backups/
	@mkdir -p backups
	@echo "Backing up streams..."
	@for stream in $$(docker-compose exec -T nats-box nats stream list --json | jq -r '.[] | .name'); do \
		echo "Backing up $$stream..."; \
		docker-compose exec -T nats-box nats stream backup $$stream /tmp/$$stream.tar.gz; \
		docker cp cim-nats-box:/tmp/$$stream.tar.gz ./backups/; \
	done
	@echo "Backup completed in ./backups/"

restore: ## Restore all streams from ./backups/
	@echo "Restoring streams from ./backups/"
	@for backup in ./backups/*.tar.gz; do \
		if [ -f "$$backup" ]; then \
			echo "Restoring $$backup..."; \
			docker cp "$$backup" cim-nats-box:/tmp/; \
			docker-compose exec -T nats-box nats stream restore "/tmp/$$(basename $$backup)"; \
		fi; \
	done
	@echo "Restore completed"

# Monitoring and debugging
debug: ## Show comprehensive debug information
	@echo "=== CIM-Start Debug Information ==="
	@echo ""
	@make status
	@echo ""
	@echo "=== JetStream Status ==="
	@docker-compose exec -T nats-box nats server report jetstream 2>/dev/null || echo "Unable to get JetStream info"
	@echo ""
	@echo "=== Stream Summary ==="
	@docker-compose exec -T nats-box nats stream list 2>/dev/null || echo "Unable to list streams"
	@echo ""
	@echo "=== Environment Variables ==="
	@echo "ENV=$(ENV)"
	@echo "NATS_URL=$(NATS_URL)"
	@echo ""
	@echo "=== Docker Resources ==="
	@docker system df

# Security targets  
security-check: ## Run basic security checks
	@echo "=== Security Check ==="
	@echo "Checking for default passwords..."
	@grep -n "password.*pass" nats.conf || echo "✓ No default passwords found in config"
	@echo ""
	@echo "Checking TLS configuration..."
	@grep -n "tls" nats.conf && echo "✓ TLS configuration found" || echo "⚠ No TLS configuration (OK for development)"
	@echo ""
	@echo "Checking account permissions..."
	@docker-compose exec -T nats-box nats server report accounts 2>/dev/null || echo "Unable to check accounts"