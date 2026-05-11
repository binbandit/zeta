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

    languages_config="$helix_config_dir/languages.toml"
    config_block_start="# just install managed language defaults"
    config_block_end="# end just install managed language defaults"

    touch "$languages_config"
    temp_languages_config="$(mktemp)"
    awk \
        -v start="$config_block_start" \
        -v end="$config_block_end" \
        '$0 == start { skip = 1; next } $0 == end { skip = 0; next } !skip { print }' \
        "$languages_config" > "$temp_languages_config"
    mv "$temp_languages_config" "$languages_config"
    {
        printf '\n%s\n' "$config_block_start"
        printf '%s\n' '[language-server.rust-analyzer]'
        printf '%s\n' 'command = "lspmux"'
        printf '%s\n\n' 'args = ["client"]'
        printf '%s\n' '[[language]]'
        printf '%s\n' 'name = "python"'
        printf '%s\n\n' 'language-servers = ["pyright"]'
        printf '%s\n' "$config_block_end"
    } >> "$languages_config"

    install_config_home="$(mktemp -d)"
    trap 'rm -rf "$install_config_home"' EXIT

    mkdir -p "$install_config_home/helix"
    ln -s "$PWD/runtime" "$install_config_home/helix/runtime"
    {
        printf '%s\n' '[use-grammars]'
        printf '%s\n' 'only = ['
        printf '  "%s",\n' \
            bash \
            css \
            diff \
            dockerfile \
            git-attributes \
            git-commit \
            git-config \
            git-ignore \
            git-rebase \
            go \
            gomod \
            gotmpl \
            html \
            javascript \
            json \
            jsonc \
            jsx \
            just \
            make \
            markdown \
            python \
            ruby \
            rust \
            scss \
            swift \
            toml \
            tsx \
            typescript \
            xml \
            yaml
        printf '%s\n' ']'
    } > "$install_config_home/helix/languages.toml"

    XDG_CONFIG_HOME="$install_config_home" hx --grammar fetch
    XDG_CONFIG_HOME="$install_config_home" hx --grammar build

    if command -v rustup >/dev/null 2>&1; then
        rustup component add rust-analyzer
    else
        printf 'Skipping rust-analyzer: rustup is not installed\n' >&2
    fi

    if command -v cargo >/dev/null 2>&1; then
        cargo install lspmux --locked
        cargo install taplo-cli --locked --features lsp
        cargo install just-lsp --locked
    fi

    if command -v go >/dev/null 2>&1; then
        go install golang.org/x/tools/gopls@latest
    else
        printf 'Skipping gopls: go is not installed\n' >&2
    fi

    if command -v gem >/dev/null 2>&1; then
        gem install ruby-lsp
    else
        printf 'Skipping ruby-lsp: gem is not installed\n' >&2
    fi

    if command -v npm >/dev/null 2>&1; then
        npm install -g \
            @microsoft/compose-language-service \
            bash-language-server \
            dockerfile-language-server-nodejs \
            pyright \
            typescript \
            typescript-language-server \
            vscode-langservers-extracted \
            yaml-language-server
    else
        printf 'Skipping npm language servers: npm is not installed\n' >&2
    fi

    if command -v brew >/dev/null 2>&1; then
        brew list marksman >/dev/null 2>&1 || brew install marksman
    else
        printf 'Skipping marksman: brew is not installed\n' >&2
    fi

    hx --health
