# Default device for run/run-reset (windows | android | macos | linux)
DEVICE ?= windows

.DEFAULT_GOAL := help
.PHONY: help get codegen watch l10n db-migrate analyze test check run run-reset clean

# --- Help -------------------------------------------------------------------

help: ## Show the list of commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

# --- Dependencies -----------------------------------------------------------

get: ## Install dependencies (flutter pub get)
	flutter pub get

# --- Code generation --------------------------------------------------------

codegen: ## Generate drift code (app_database.g.dart) via build_runner
	dart run build_runner build --delete-conflicting-outputs

watch: ## Watch for changes and regenerate code automatically
	dart run build_runner watch --delete-conflicting-outputs

l10n: ## Generate localizations (flutter gen-l10n)
	flutter gen-l10n

# --- Database (drift migrations) --------------------------------------------
# NOTE: make-migrations is a two-phase command:
#   1st run (schemaVersion = 1) — creates ONLY the schema snapshot
#     drift_schemas/<db>/drift_schema_v1.json (this is not an error!).
#   2nd run (after bumping schemaVersion in app_database.dart) —
#     generates app_database.steps.dart and tests in test/drift/.

db-migrate: ## Dump drift schema snapshot / migration steps (see note above)
	dart run drift_dev make-migrations

# --- Checks -----------------------------------------------------------------

analyze: ## Static analysis (flutter analyze)
	flutter analyze

test: ## Run tests
	flutter test

check: analyze test ## analyze + test (run before committing)

# --- Run --------------------------------------------------------------------

run: ## Run the app on $(DEVICE)
	flutter run -d $(DEVICE)

run-reset: ## Run with a local DB reset (dev flag MAGPIE_NEST_RESET_DB)
	flutter run -d $(DEVICE) --dart-define=MAGPIE_NEST_RESET_DB=true

# --- Misc -------------------------------------------------------------------

clean: ## Clean build artifacts
	flutter clean
