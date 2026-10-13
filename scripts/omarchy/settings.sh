#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == Linux ]] || { echo "Omarchy Linux is required" >&2; exit 1; }

# Run as the login user; only the explicit system operations need elevation.
privileged() {
    if [[ -t 0 ]]; then sudo "$@"; else pkexec "$@"; fi
}

# Keep system configuration outside Stow and avoid rewriting identical files.
keyd_changed=false
for source in "$ROOT"/system/omarchy/etc/keyd/*.conf; do
    target="/etc/keyd/$(basename "$source")"
    if ! cmp -s "$source" "$target"; then
        if [[ -e "$target" ]]; then
            privileged cp -a "$target" "$target.pre-dotfiles.$(date +%Y%m%d-%H%M%S)"
        fi
        privileged install -Dm644 "$source" "$target"
        keyd_changed=true
    fi
done
keyd check
if ! systemctl is-enabled --quiet keyd || ! systemctl is-active --quiet keyd; then
    privileged systemctl enable --now keyd
fi
if $keyd_changed; then privileged keyd reload; fi

# fnm owns Node for the shared Zsh configuration; do not change mise projects.
eval "$(fnm env --shell bash)"
if ! fnm use default >/dev/null 2>&1; then
    fnm install --lts
    fnm use --lts
    fnm default "$(fnm current)"
    fnm use default
fi
for package in oxfmt pnpm; do
    [[ -x "$(npm prefix -g)/bin/$package" ]] || npm install --global "$package"
done

# Model files are runtime data, never part of a Stow package.
model=parakeet-tdt-0.6b-v3-int8
model_dir="${XDG_DATA_HOME:-$HOME/.local/share}/voxtype/models/$model"
if [[ "$(readlink -f "$(command -v voxtype)")" != */voxtype-onnx-avx2 ]]; then
    privileged voxtype setup onnx --enable
fi
if [[ ! -s "$model_dir/encoder-model.int8.onnx" ||
      ! -s "$model_dir/decoder_joint-model.int8.onnx" ||
      ! -s "$model_dir/vocab.txt" || ! -s "$model_dir/config.json" ]]; then
    setup_config_root="$(mktemp -d)"
    trap 'rm -rf -- "$setup_config_root"' EXIT
    install -Dm600 "$HOME/.config/voxtype/config.toml" "$setup_config_root/voxtype/config.toml"
    XDG_CONFIG_HOME="$setup_config_root" voxtype setup --download --model "$model" --no-post-install
    rm -rf -- "$setup_config_root"
    trap - EXIT
fi
systemctl --user enable --now voxtype.service
systemctl --user restart voxtype.service

if [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" != /usr/bin/zsh ]]; then
    privileged chsh -s /usr/bin/zsh "$(id -un)"
    echo "Login shell changed to Zsh. Log out and back in to refresh the session environment."
fi
