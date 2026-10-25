# Default device for run/run-reset (windows | android | macos | linux)
DEVICE ?= windows

.DEFAULT_GOAL := help
.PHONY: help get codegen watch l10n db-migrate analyze test check run run-reset run-driver run-driver-reset clean

help: ## Show the list of commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

get: ## Install dependencies (flutter pub get)
	flutter pub get

codegen: ## Generate drift code (app_database.g.dart) via build_runner
	dart run build_runner build --delete-conflicting-outputs

watch: ## Watch for changes and regenerate code automatically
	dart run build_runner watch --delete-conflicting-outputs

l10n: ## Generate localizations (flutter gen-l10n)
	flutter gen-l10n

db-migrate: ## Dump drift schema snapshot / migration steps (see note above)
	dart run drift_dev make-migrations

analyze: ## Static analysis (flutter analyze)
	flutter analyze

test: ## Run tests
	flutter test

check: analyze test ## analyze + test (run before committing)

run: ## Run the app on $(DEVICE)
	flutter run -d $(DEVICE)

run-reset: ## Run with a local DB reset (dev flag MAGPIE_NEST_RESET_DB)
	flutter run -d $(DEVICE) --dart-define=MAGPIE_NEST_RESET_DB=true

run-driver: ## Run the app with the Flutter Driver extension (driver_main.dart)
	flutter run -d $(DEVICE) -t lib/driver_main.dart

run-driver-reset: ## Run driver entrypoint with a local DB reset (dev flag MAGPIE_NEST_RESET_DB)
	flutter run -d $(DEVICE) -t lib/driver_main.dart --dart-define=MAGPIE_NEST_RESET_DB=true

clean: ## Clean build artifacts
	flutter clean
