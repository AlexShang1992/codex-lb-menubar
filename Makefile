# CodexBar — build helpers
# Requires only the Xcode Command Line Tools (swiftc), no full Xcode.

APP := CodexBar.app

.PHONY: all build icons run selftest clean

all: build ## Build the app bundle (default)

build: ## Compile and assemble CodexBar.app
	./build.sh

icons: ## Regenerate menu-bar and app icons into Resources/
	./make-icons.sh

run: build ## Build then launch the app
	open ./$(APP)

selftest: build ## Headless fetch + decode check against the local codex-lb API
	./$(APP)/Contents/MacOS/CodexBar --selftest

clean: ## Remove build output
	rm -rf ./$(APP) build dist

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
