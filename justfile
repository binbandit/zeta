# Build and install commands for za editor

# Default recipe
default:
    @just --list

# Build the za binary
build:
    cargo build --release

# Build the za binary in debug mode
build-debug:
    cargo build

# Install the za binary to system
install: build
    @echo "Installing za to /usr/local/bin/"
    sudo cp target/release/za /usr/local/bin/
    sudo chmod +x /usr/local/bin/za
    @echo "✓ za installed successfully"

# Install to user directory (no sudo required)
install-user: build
    @echo "Installing za to ~/.local/bin/"
    mkdir -p ~/.local/bin
    cp target/release/za ~/.local/bin/
    chmod +x ~/.local/bin/za
    @echo "✓ za installed to ~/.local/bin/"
    @echo "Make sure ~/.local/bin is in your PATH"

# Clean build artifacts
clean:
    cargo clean

# Run tests
test:
    cargo test

# Check code
check:
    cargo check
    cargo clippy -- -D warnings

# Format code
fmt:
    cargo fmt

# Watch for changes, run cargo check, and if successful, build and install
watch:
    cargo watch --shell "if cargo check; then echo '✓ Check passed, building and installing...'; cargo build --release && echo '✓ Build complete, installing...' && just install-user; else echo '✗ Check failed'; fi"

# Watch in debug mode (no install)
watch-debug:
    cargo watch -x "build --bin za"

# Run the editor
run *args:
    ./target/debug/za {{args}}

# Run the release build
run-release *args:
    ./target/release/za {{args}}

# Build documentation
docs:
    cargo doc --no-deps

# Update dependencies
update:
    cargo update

# Build with all features
build-all:
    cargo build --release --all-features