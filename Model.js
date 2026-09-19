// Model.js - Helper and formatting functions for Touchpad Edge Controls

function defaultConfig() {
    return {
        "enabled": true,
        "volume_enabled": true,
        "brightness_enabled": true,
        "swap_edges": false,
        "edge_start_percent": 0.10,
        "edge_cancel_percent": 0.16,
        "step_travel_px": 45,
        "volume_step": 2,
        "brightness_step": 2,
        "invert_direction": false,
        "device_name": "Touchpad",
        "device_found": true
    };
}

function formatDeviceName(rawName) {
    if (!rawName) return "Laptop Touchpad";
    var name = String(rawName).replace(/MSFT[0-9]+:[0-9]+\s*/i, "").replace(/[0-9A-Fa-f]{4}:[0-9A-Fa-f]{4}\s*/, "").trim();
    return name || "Laptop Touchpad";
}

function formatStep(step) {
    var s = Number(step) || 2;
    return "±" + s + "% per swipe";
}

function formatEdgeWidth(pct) {
    var p = Math.round((Number(pct) || 0.10) * 100);
    return p + "% strip";
}

function getTooltipText(cfg) {
    if (!cfg) return "Touchpad Edge Controls";
    if (!cfg.enabled) return "Touchpad Edge Controls (Disabled)";
    var v = cfg.volume_step || 2;
    var b = cfg.brightness_step || 2;
    var vLabel = cfg.volume_enabled ? ("Vol ±" + v + "%") : "Vol OFF";
    var bLabel = cfg.brightness_enabled ? ("Bri ±" + b + "%") : "Bri OFF";

    if (cfg.swap_edges) {
        return "Touchpad Edge: Left (" + vLabel + ") · Right (" + bLabel + ")";
    } else {
        return "Touchpad Edge: Left (" + bLabel + ") · Right (" + vLabel + ")";
    }
}
