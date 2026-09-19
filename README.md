# 󰍽 Touchpad Edge Controls for Omarchy

[![Omarchy Plugin](https://img.shields.io/badge/Omarchy-Quattro%20Plugin-blue)](https://omarchy.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Transform your laptop touchpad into intuitive, dual-edge hardware sliders for **Volume** and **Brightness** on [Omarchy](https://omarchy.org) Linux (Hyprland + Quickshell).

---

## ✨ Features

- **🔊 Right Edge Slider**: Slide your finger vertically along the far right edge of your touchpad to raise or lower the audio volume.
- **☀️ Left Edge Slider**: Slide your finger vertically along the far left edge of your touchpad to brighten or dim your display.
- **🎛️ Complete Customization & Control**:
  - **Master ON / OFF**: Instant toggle for all gestures.
  - **Swap Sides ⇄**: Freely swap edge roles (Left: Volume / Right: Brightness OR Left: Brightness / Right: Volume).
  - **Individual Sliders**: Disable Brightness or Volume separately.
  - **Fine-Grained Step Tuning**: Adjust exactly how much volume and brightness change per small swipe (from `±1%` up to `±10%`, with instant `1%`, `2%`, `3%`, `5%`, `10%` preset pills).
  - **Edge Width Calibration**: Customize the active strip width (`8%`, `10%`, `14%`).
  - **Invert Direction**: Swipe up or down to your personal preference.
- **🖥️ Native Omarchy OSD Feedback**: Seamlessly displays Omarchy's centered on-screen display (OSD) HUD in real-time as you swipe.
- **🛡️ Palm & Accidental Touch Rejection**:
  - Edge gestures **only** activate if your touch starts directly on the outer edge.
  - Normal pointer motion starting anywhere in the center 80% will never trigger volume or brightness, even if your finger wanders toward the edges.
- **✌️ Multi-Touch Bypass**: Two-finger scrolling, pinch-to-zoom, and 3/4-finger workspace gestures are instantly recognized and completely uninterrupted.
- **📊 Omarchy Bar Widget & Native Popup Card**: Click the touchpad icon (`󰍽`) in your Omarchy status bar to open the settings panel; right-click for instant master toggle!
- **⚡ Ultra-low Overhead**: Lightweight, event-driven Python daemon with debounced asynchronous execution (~1.2 MB RAM, <0.01% CPU).

---

## 🚀 Quick Installation

### 1. Add the Plugin via Omarchy CLI
```bash
omarchy plugin add https://github.com/omshankara/omarchy-touchpad-edge.git --enable
```

### 2. Configure Device Permissions (One-Time Setup)
To allow reading touchpad touch coordinates without root, run the setup script:
```bash
cd ~/.config/omarchy/plugins/omshankara.touchpad-edge
./install.sh
```
*(Or manually copy `udev/71-touchpad-edge.rules` to `/etc/udev/rules.d/` and reload `udevadm control --reload-rules && udevadm trigger --subsystem-match=input`)*.

---

## 🎮 How to Use

| Edge (Default) | Edge (Swapped) | Direction | Action | Feedback |
| :--- | :--- | :--- | :--- | :--- |
| **Right Edge** | **Left Edge** | Swipe **Up** | **Volume Up** (+2%) | Omarchy Volume OSD 🔊 |
| **Right Edge** | **Left Edge** | Swipe **Down** | **Volume Down** (-2%) | Omarchy Volume OSD 🔉 |
| **Left Edge** | **Right Edge** | Swipe **Up** | **Brightness Up** (+2%) | Omarchy Brightness OSD ☀️ |
| **Left Edge** | **Right Edge** | Swipe **Down** | **Brightness Down** (-2%) | Omarchy Brightness OSD 🌙 |

> **Tip:** You only need a gentle, single-finger slide along the outer edge border of your trackpad.

---

## ⚙️ Configuration

Options can be customized via the status bar popup panel or directly in `~/.config/omarchy/touchpad-edge.json`:

```json
{
  "enabled": true,
  "volume_enabled": true,
  "brightness_enabled": true,
  "swap_edges": false,
  "edge_start_percent": 0.10,
  "edge_cancel_percent": 0.16,
  "step_travel_px": 45,
  "volume_step": 2,
  "brightness_step": 2,
  "invert_direction": false
}
```

- **`swap_edges`**: Set to `true` to place Volume on the Left and Brightness on the Right (default: `false`).
- **`edge_start_percent`**: Width of the edge detection strip (default: `0.10` = outer 10%).
- **`volume_step` / `brightness_step`**: Percentage change per tick (default: `2`%).
- **`step_travel_px`**: Touchpad travel distance required per adjustment tick (~1.5 mm).
- **`invert_direction`**: Reverse swipe direction if preferred.

---

## 🛠️ Requirements

- **Omarchy Linux** (Quickshell + Hyprland)
- Python 3 with `python-evdev` (`sudo pacman -S --needed python-evdev`)
- `brightnessctl` (pre-installed on Omarchy)
- Standard multi-touch laptop touchpad (I2C / HID / PS/2)

---

## 📄 License

MIT License. Crafted with precision for the Omarchy community by [omshankara](https://github.com/omshankara).
