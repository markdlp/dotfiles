#!/usr/bin/env bash
# ==============================================================================
# restore_ssh_keys.sh
# Restores SSH private keys from your Bitwarden vault into ~/.ssh/ and locks
# down permissions (chmod 600 private keys, chmod 644 public keys).
# Alternatively syncs from Windows host when running under WSL.
# ==============================================================================

set -euo pipefail

ITEM_NAME="${1:-SSH Keys}"
SSH_DIR="$HOME/.ssh"
WIN_SSH_DIR="/mnt/c/Users/mark/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

KEYS=(
  "id_aspire"
  "id_gh_win"
  "id_gitkraken"
  "id_myHair"
  "id_mySkull"
  "id_myWaist"
  "id_zafora"
)

# Function to fix permissions
fix_permissions() {
  echo "==> Locking down SSH permissions..."
  chmod 700 "$SSH_DIR"
  for key in "${KEYS[@]}"; do
    if [[ -f "$SSH_DIR/$key" ]]; then
      chmod 600 "$SSH_DIR/$key"
    fi
    if [[ -f "$SSH_DIR/$key.pub" ]]; then
      chmod 644 "$SSH_DIR/$key.pub"
    fi
  done
  if [[ -f "$SSH_DIR/config" ]]; then
    chmod 600 "$SSH_DIR/config"
  fi
  if [[ -f "$SSH_DIR/known_hosts" ]]; then
    chmod 644 "$SSH_DIR/known_hosts"
  fi
  echo "==> Permissions secured."
}

# 1. Quick sync from Windows if keys already exist there under WSL
if [[ -d "$WIN_SSH_DIR" && -f "$WIN_SSH_DIR/id_myWaist" ]]; then
  echo "==> Found existing SSH keys in Windows profile ($WIN_SSH_DIR)."
  read -r -p "Do you want to sync directly from Windows .ssh? [Y/n] " response
  response=${response:-Y}
  if [[ "$response" =~ ^[Yy]$ ]]; then
    for key in "${KEYS[@]}"; do
      if [[ -f "$WIN_SSH_DIR/$key" ]]; then
        echo "  -> Copying $key to $SSH_DIR/$key"
        cp "$WIN_SSH_DIR/$key" "$SSH_DIR/$key"
      fi
      if [[ -f "$WIN_SSH_DIR/$key.pub" ]]; then
        cp "$WIN_SSH_DIR/$key.pub" "$SSH_DIR/$key.pub"
      fi
    done
    if [[ -f "$WIN_SSH_DIR/config" && ! -f "$SSH_DIR/config" ]]; then
      echo "  -> Copying SSH config"
      cp "$WIN_SSH_DIR/config" "$SSH_DIR/config"
    fi
    fix_permissions
    echo "==> SSH keys restored from Windows profile successfully!"
    exit 0
  fi
fi

# 2. Bitwarden CLI retrieval
if ! command -v bw &>/dev/null; then
  echo "Error: Bitwarden CLI ('bw') is not found in PATH." >&2
  echo "Please ensure 'bitwarden-cli' is installed (run: nixos-rebuild switch --flake ~/dotfiles/nix#wsl)." >&2
  exit 1
fi

if [[ -z "${BW_SESSION:-}" ]]; then
  echo "==> BW_SESSION not detected. Unlocking Bitwarden vault..."
  BW_SESSION=$(bw unlock --raw)
  export BW_SESSION
fi

echo "==> Syncing Bitwarden vault..."
bw sync >/dev/null

echo "==> Retrieving vault item '$ITEM_NAME'..."
ITEM_JSON=$(bw get item "$ITEM_NAME")
ITEM_ID=$(echo "$ITEM_JSON" | grep -o '"id":"[^"]*' | head -n1 | cut -d'"' -f4)

for key in "${KEYS[@]}"; do
  echo "  -> Downloading $key from Bitwarden item $ITEM_NAME..."
  if bw get attachment "$key" --itemid "$ITEM_ID" --output "$SSH_DIR/$key" &>/dev/null; then
    echo "     Downloaded $key successfully."
  else
    echo "     Warning: attachment $key not found in item $ITEM_NAME."
  fi
done

fix_permissions
echo "==> SSH private keys restored from Bitwarden successfully!"
