# Build the helix binary (release mode)
build:
    cargo build --release

# Run all tests across the workspace
test:
    cargo test --workspace

# Install Helix, runtime files, grammars, and common Helix-development language servers
install:
    #!/usr/bin/env bash
    set -euo pipefail

    HELIX_DISABLE_AUTO_GRAMMAR_BUILD=1 cargo install --path helix-term --locked

    config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    helix_config_dir="$config_home/helix"
    runtime_link="$helix_config_dir/runtime"

    mkdir -p "$helix_config_dir"
    if [ -e "$runtime_link" ] && [ ! -L "$runtime_link" ]; then
        printf 'Refusing to replace non-symlink runtime directory: %s\n' "$runtime_link" >&2
        exit 1
    fi
    rm -f "$runtime_link"
    ln -s "$PWD/runtime" "$runtime_link"

    fetch_and_build_grammars() {
        if hx --grammar fetch && hx --grammar build; then
            return 0
        fi

        printf 'Failed to fetch or build all grammars; retrying without GitLab-hosted grammars\n' >&2
        gitlab_free_config_home="$(mktemp -d)"
        trap 'rm -rf "$gitlab_free_config_home"' EXIT

        mkdir -p "$gitlab_free_config_home/helix"
        ln -s "$PWD/runtime" "$gitlab_free_config_home/helix/runtime"
        printf '%s\n' 'use-grammars = { except = [ "blueprint", "debian", "lpf", "nginx", "rpmspec", "t32" ] }' > "$gitlab_free_config_home/helix/languages.toml"

        XDG_CONFIG_HOME="$gitlab_free_config_home" hx --grammar fetch
        XDG_CONFIG_HOME="$gitlab_free_config_home" hx --grammar build
    }

    fetch_and_build_grammars

    if command -v rustup >/dev/null 2>&1; then
        rustup component add rust-analyzer
    else
        printf 'Skipping rust-analyzer: rustup is not installed\n' >&2
    fi

    if command -v cargo >/dev/null 2>&1; then
        cargo install taplo-cli --locked --features lsp
        cargo install just-lsp --locked
    fi

    if command -v npm >/dev/null 2>&1; then
        npm install -g bash-language-server typescript typescript-language-server vscode-langservers-extracted
    else
        printf 'Skipping npm language servers: npm is not installed\n' >&2
    fi

    if command -v brew >/dev/null 2>&1; then
        brew list marksman >/dev/null 2>&1 || brew install marksman
    else
        printf 'Skipping marksman: brew is not installed\n' >&2
    fi

    hx --health
