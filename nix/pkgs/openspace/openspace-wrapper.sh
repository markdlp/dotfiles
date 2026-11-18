#!/usr/bin/env bash
set -euo pipefail

# Print help if requested
if [[ " $* " == *" --help "* ]] || [[ " $* " == *" -h "* ]]; then
  echo "OpenSpace NixOS Launcher"
  echo "Usage: openspace [options] [-- openspace_args...]"
  echo ""
  echo "Options:"
  echo "  --igpu        Run on integrated graphics (AMD) instead of dedicated NVIDIA GPU"
  echo "  --debug       Enable verbose launcher and Qt debug output"
  echo "  --help, -h    Show this help message"
  echo ""
  echo "Environment variables honored:"
  echo "  OPENSPACE_SYNC           Path to asset sync root (default: \$XDG_DATA_HOME/openspace/sync)"
  echo "  OPENSPACE_USER           Path to user data root (default: \$XDG_DATA_HOME/openspace/user)"
  echo "  OPENSPACE_GLOBEBROWSING  Path to map cache root (default: \$XDG_CACHE_HOME/openspace/globebrowsing)"
  echo ""
  echo "All other arguments are passed directly to OpenSpace."
  exit 0
fi

# 1. State and Asset Paths (XDG Compliant)
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/openspace"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/openspace"

export OPENSPACE_SYNC="${OPENSPACE_SYNC:-$DATA_HOME/sync}"
export OPENSPACE_USER="${OPENSPACE_USER:-$DATA_HOME/user}"
export OPENSPACE_GLOBEBROWSING="${OPENSPACE_GLOBEBROWSING:-$CACHE_HOME/globebrowsing}"

mkdir -p "$OPENSPACE_SYNC" "$OPENSPACE_USER" "$OPENSPACE_GLOBEBROWSING"

# 2. Argument Parsing
USE_NVIDIA=1
DEBUG=0
PASSTHROUGH_ARGS=()

for arg in "$@"; do
  case "$arg" in
    --igpu)
      USE_NVIDIA=0
      ;;
    --debug)
      DEBUG=1
      ;;
    *)
      PASSTHROUGH_ARGS+=("$arg")
      ;;
  esac
done

# 3. GPU Offload Configuration
if [ "$USE_NVIDIA" -eq 1 ]; then
  # On hybrid setups with NVIDIA proprietary driver, set prime offload
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only
  if [ "$DEBUG" -eq 1 ]; then
    echo "[openspace] Running with NVIDIA PRIME render offload enabled"
  fi
else
  if [ "$DEBUG" -eq 1 ]; then
    echo "[openspace] Running with Integrated GPU"
  fi
fi

# 4. Qt and Display Configuration
# OpenSpace Launcher UI uses bundled Qt6 with xcb platform plugin
export QT_PLUGIN_PATH="@EXTRACTED_APPDIR@/usr/lib/x86_64-linux-gnu/qt6/plugins:${QT_PLUGIN_PATH:-}"
export QT_QPA_PLATFORM=xcb
export GDK_BACKEND=x11

if [ "$DEBUG" -eq 1 ]; then
  export QT_DEBUG_PLUGINS=1
  echo "[openspace] OPENSPACE_SYNC=$OPENSPACE_SYNC"
  echo "[openspace] OPENSPACE_USER=$OPENSPACE_USER"
  echo "[openspace] OPENSPACE_GLOBEBROWSING=$OPENSPACE_GLOBEBROWSING"
  echo "[openspace] QT_PLUGIN_PATH=$QT_PLUGIN_PATH"
  echo "[openspace] Launching: @RAW_OPENSPACE@ ${PASSTHROUGH_ARGS[*]}"
fi

exec "@RAW_OPENSPACE@" "${PASSTHROUGH_ARGS[@]}"
