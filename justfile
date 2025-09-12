# Justfile for Helix editor build and development

# Default target
default:
    @just --list

# Build the project in debug mode
build:
    cargo build

# Build the project in release mode
build-release:
    cargo build --release

# Run cargo check to validate code without building
check:
    cargo check

# Run tests
test:
    cargo test

# Install the binary globally using cargo install
install:
    cargo install --path helix-term

# Install the binary globally (release mode)
install-release:
    cargo install --path helix-term --release

# Build and install in one command
build-and-install:
    cargo build
    cargo install --path helix-term

# Clean build artifacts
clean:
    cargo clean

# Watch for changes and automatically run cargo check then install
watch:
    cargo watch -x 'check' -x 'install --path helix-term'

# Watch for changes and automatically run cargo check then install (release mode)
watch-release:
    cargo watch -x 'check' -x 'install --path helix-term --release'

# Format code
fmt:
    cargo fmt

# Lint code
lint:
    cargo clippy -- -D warnings

# Run fmt, lint, and check
check-all: fmt lint check