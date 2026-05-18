#!/usr/bin/env sh
#
# AMA2 CLI installer.
# Detects OS/arch, downloads the matching binary from GitHub Releases,
# installs it to a directory on PATH (default ~/.local/bin — no sudo needed).
#
# Usage:
#   curl -fsSL https://ama2.me/install.sh | sh
#   curl -fsSL https://ama2.me/install.sh | sh -s -- --version v1.0.0
#   curl -fsSL https://ama2.me/install.sh | sh -s -- --bin-dir /usr/local/bin
#

set -eu

REPO="ama2-team/ama2-public"
BIN_NAME="ama2"
VERSION="latest"
# Default install location — XDG-conventional, writable without sudo on the
# host user's account. Pass --bin-dir /usr/local/bin (or any directory) to
# override. /usr/local/bin is intentionally NOT the default any more: it
# requires sudo and silently blocks autonomous setup agents.
BIN_DIR="${HOME}/.local/bin"

usage() {
  cat <<EOF
Usage: install.sh [--version <vX.Y.Z>] [--bin-dir <path>]

Options:
  --version    Release tag to install (default: latest)
  --bin-dir    Install location (default: \$HOME/.local/bin)
  -h, --help   Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    --bin-dir) BIN_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

# --- detect OS ---
uname_s="$(uname -s)"
case "$uname_s" in
  Linux) os="linux" ;;
  Darwin) os="darwin" ;;
  MINGW*|MSYS*|CYGWIN*) os="windows" ;;
  *) echo "unsupported OS: $uname_s" >&2; exit 1 ;;
esac

# --- detect arch ---
uname_m="$(uname -m)"
case "$uname_m" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) echo "unsupported arch: $uname_m" >&2; exit 1 ;;
esac

# --- resolve version ---
if [ "$VERSION" = "latest" ]; then
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -o '"tag_name":[[:space:]]*"[^"]*"' \
    | head -1 \
    | sed 's/.*"\([^"]*\)"$/\1/')"
  if [ -z "$VERSION" ]; then
    echo "could not determine latest version" >&2
    exit 1
  fi
fi

ext="tar.gz"
[ "$os" = "windows" ] && ext="zip"

archive="${BIN_NAME}_${VERSION#v}_${os}_${arch}.${ext}"
url="https://github.com/${REPO}/releases/download/${VERSION}/${archive}"

echo "AMA2 CLI installer"
echo "  version : ${VERSION}"
echo "  os/arch : ${os}/${arch}"
echo "  archive : ${archive}"
echo "  install : ${BIN_DIR}/${BIN_NAME}"
echo

# --- download ---
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading ${url}..."
if ! curl -fsSL -o "${tmp}/${archive}" "$url"; then
  echo "download failed: $url" >&2
  exit 1
fi

# --- extract ---
cd "$tmp"
if [ "$ext" = "zip" ]; then
  unzip -q "$archive"
else
  tar -xzf "$archive"
fi

if [ ! -f "$BIN_NAME" ] && [ ! -f "${BIN_NAME}.exe" ]; then
  echo "binary not found in archive" >&2
  exit 1
fi

src="${BIN_NAME}"
[ -f "${BIN_NAME}.exe" ] && src="${BIN_NAME}.exe"

# --- install ---
mkdir -p "$BIN_DIR" 2>/dev/null || true
if [ -w "$BIN_DIR" ]; then
  install -m 0755 "$src" "${BIN_DIR}/${BIN_NAME}"
else
  echo "Elevated permission needed to write to ${BIN_DIR}."
  sudo install -m 0755 "$src" "${BIN_DIR}/${BIN_NAME}"
fi

echo
echo "Installed: ${BIN_DIR}/${BIN_NAME}"
"${BIN_DIR}/${BIN_NAME}" --version 2>/dev/null || echo "(run \`${BIN_NAME} --help\` to verify)"

# --- PATH check ---
# If the install location is not on PATH, the binary is invisible. Emit a
# one-shot export + a persistent-rc line for the user/agent to copy. We do
# NOT auto-edit shell rc files — that is too invasive for a curl|sh script.
case ":${PATH}:" in
  *":${BIN_DIR}:"*) on_path=1 ;;
  *) on_path=0 ;;
esac

if [ "$on_path" -eq 0 ]; then
  echo
  echo "⚠️  ${BIN_DIR} is not on your PATH."
  echo "Add it for the current shell:"
  echo "  export PATH=\"${BIN_DIR}:\$PATH\""
  echo "And persist it (pick one matching your shell):"
  echo "  echo 'export PATH=\"${BIN_DIR}:\$PATH\"' >> ~/.zshrc      # zsh"
  echo "  echo 'export PATH=\"${BIN_DIR}:\$PATH\"' >> ~/.bashrc     # bash"
fi

echo
echo "Next steps:"
echo "  ${BIN_NAME} auth login"
echo "  ${BIN_NAME} agents list                                  # find your agent's actor_id"
echo "  ${BIN_NAME} profiles add <agent_actor_id> --as work"
echo "  export AMA2_PROFILE=work"
echo "  ${BIN_NAME} owner me                                     # verify"
echo
echo "No agents yet? Create one at: https://ama2.me/settings/agents"
echo "Docs: https://github.com/ama2-team/ama2-public#readme"
