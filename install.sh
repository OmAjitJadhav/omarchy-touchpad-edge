#!/bin/bash
set -euo pipefail

echo "==> Installing Touchpad Edge Controls permissions..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UDEV_RULE="/etc/udev/rules.d/71-touchpad-edge.rules"

if [[ ! -f "$UDEV_RULE" ]]; then
  echo "==> Setting up udev rule for touchpad access (requires sudo/pkexec)..."
  if command -v pkexec >/dev/null 2>&1; then
    pkexec cp "$SCRIPT_DIR/udev/71-touchpad-edge.rules" "$UDEV_RULE"
    pkexec udevadm control --reload-rules
    pkexec udevadm trigger --subsystem-match=input
  elif command -v sudo >/dev/null 2>&1; then
    sudo cp "$SCRIPT_DIR/udev/71-touchpad-edge.rules" "$UDEV_RULE"
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=input
  else
    echo "Warning: Could not install udev rule automatically. Please run as root:"
    echo "  cp $SCRIPT_DIR/udev/71-touchpad-edge.rules $UDEV_RULE && udevadm control --reload-rules && udevadm trigger --subsystem-match=input"
  fi
fi

# Ensure python-evdev is installed
if ! /usr/bin/python3 -c "import evdev" 2>/dev/null; then
  echo "==> Installing python-evdev package..."
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed python-evdev || true
  fi
fi

echo "==> Touchpad Edge Controls setup completed successfully!"
