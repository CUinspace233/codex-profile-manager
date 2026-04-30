#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
install_dir="${PREFIX:-$HOME/.local}/bin"

mkdir -p "$install_dir"

cp "$project_dir/bin/codex-profile" "$install_dir/codex-profile"
chmod +x "$install_dir/codex-profile"

ln -sf "$install_dir/codex-profile" "$install_dir/cx"

cat <<EOF
Installed:
  $install_dir/codex-profile
  $install_dir/cx

Try:
  cx --help
EOF
