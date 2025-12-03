SHELL := /usr/bin/env bash
NIGHTLY_TOOLCHAIN := nightly

.PHONY: format \
	clippy test check-features build all-checks nightly-version


# Print the nightly toolchain version for CI
nightly-version:
	@echo $(NIGHTLY_TOOLCHAIN)

format:
	@cargo +$(NIGHTLY_TOOLCHAIN) fmt --all -- --check

format-fix:
	@cargo +$(NIGHTLY_TOOLCHAIN) fmt --all

clippy:
	@cargo +$(NIGHTLY_TOOLCHAIN) clippy --all --all-features --all-targets -- -D warnings

clippy-fix:
	@cargo +$(NIGHTLY_TOOLCHAIN) clippy --all --all-features --all-targets --fix --allow-dirty --allow-staged -- -D warnings

check-features:
	@cargo hack --feature-powerset --no-dev-deps check

build:
	@cargo build

test:
	@$(MAKE) build
	@cargo test --all-features

config-file:
	@if [ ! -f ~/.config/scilla.toml ]; then  \
		  echo "Creating default config file at ~/.config/scilla.toml if it doesn't exist..."; \
			echo 'rpc-url = "https://api.mainnet-beta.solana.com"' > ~/.config/scilla.toml; \
			echo 'keypair-path = "'$$HOME'/.config/solana/id.json"' >> ~/.config/scilla.toml; \
			echo 'commitment-level = "confirmed"' >> ~/.config/scilla.toml; \
	else \
			echo "Config file already exists at ~/.config/scilla.toml"; \
	fi
	@echo ""
	@echo "Current contents of the config file:"
	@cat ~/.config/scilla.toml

# Run all checks in sequence
all-checks:
	@echo "Running all checks..."
	@$(MAKE) format
	@$(MAKE) clippy
	@$(MAKE) check-features
	@$(MAKE) test
	@echo "All checks passed!"