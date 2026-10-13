opencode-sandbox() {
    echo "Creating sandbox..."
    local project_dir="$PWD"
    local oc_bin
    oc_bin="$(command -v opencode)" || { echo "opencode not found"; return 1; }
    oc_bin="$(readlink -f "$oc_bin")"

    if [[ "$project_dir" == "$HOME" || "$project_dir" == "/" ]]; then
      echo "Refusing to sandbox $project_dir; cd into a project first"; return 1
    fi

    # Writable state (must exist before bwrap)
    local rw_dirs=(
      "$HOME/.local/share/opencode"   # sessions, shared across all projects
      "$HOME/.local/state/opencode"
      "$HOME/.cache/opencode"
      # cargo 
      "$HOME/.cargo/registry" 
      "$HOME/.cargo/git"
      # node
      "$HOME/.npm" 
      "$HOME/.cache/pnpm"
      "$HOME/.local/share/pnpm/store"
      # go
      "$HOME/.go/pkg"
      "$HOME/.cache/go-build"
      # python
      "$HOME/.cache/uv"
      # java
      "$HOME/.m2/repository"
      "$HOME/.m2/wrapper"
    )
    # Read-only toolchains/config (add more as needed)
    local ro_dirs=(
      "$HOME/.dotfiles"
      "$HOME/.config/opencode"
      "$HOME/.gitconfig"
      "$HOME/.local/bin"
      # models 
      "$HOME/models"
      # rust
      "$HOME/.rustup"
      "$HOME/.cargo/bin"
      "$HOME/.cargo/config.toml"
      # node 
      "$HOME/.nvm"
      "$HOME/.local/share/pnpm"
      "$HOME/.local/state/pnpm"
      # python 
      "$HOME/.local/share/uv"
    )

    local d
    for d in "${rw_dirs[@]}"; do 
      if [[ ! -d "$d" ]]; then 
          echo "Missing required folder: $d"; return 1
      fi
    done

    local args=(
      --unshare-all --share-net --die-with-parent --clearenv
      --dev /dev --proc /proc --tmpfs /tmp
      --ro-bind /usr /usr
      --ro-bind-try /bin /bin
      --ro-bind-try /lib /lib
      --ro-bind-try /lib64 /lib64
      --ro-bind /etc /etc
      --ro-bind-try /run/systemd/resolve /run/systemd/resolve
      --tmpfs "$HOME"                 # first, so the binds below land on top
    )

    for d in "${ro_dirs[@]}"; do args+=(--ro-bind-try "$d" "$d"); done
    for d in "${rw_dirs[@]}"; do args+=(--bind "$d" "$d"); done

    # opencode binary, if it lives under $HOME
    case "$oc_bin" in "$HOME"/*) args+=(--ro-bind "$oc_bin" "$oc_bin") ;; esac

    args+=(
      --bind "$project_dir" "$project_dir"
      --chdir "$project_dir"
      --setenv HOME "$HOME"
      --setenv PATH "$PATH"
      --setenv TERM "${TERM:-xterm-256color}"
      --setenv LANG "${LANG:-C.UTF-8}"
    )

    local passthrough_vars=(
      SHELL USER LOGNAME COLORTERM TZ LC_ALL
      JAVA_HOME PNPM_HOME GOPATH 
      MAVEN_HOME M2_HOME MAVEN_OPTS
      CARGO_HOME RUSTUP_HOME RUSTFLAGS
    )

    # Optional passthrough, only if set (e.g. custom local server address)
    local v
    for v in "${passthrough_vars[@]}"; do
        [[ -n "$(printenv "$v")" ]] && args+=(--setenv "$v" "$(printenv "$v")")
    done

    # Optional: block git hooks tampering
    [[ -d "$project_dir/.git/hooks" ]] && \
      args+=(--ro-bind "$project_dir/.git/hooks" "$project_dir/.git/hooks")

    bwrap "${args[@]}" "$oc_bin" --standalone "$@"
}
