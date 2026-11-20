-- Void Linux / Dell XPS 13 9350 host-specific Hyprland overrides.

-- Built-in display: 1920x1200 @ 120Hz
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200@120",
    position = "auto",
    scale    = 1,
})

-- Logitech M240 Bluetooth Mouse: lower sensitivity, no acceleration
hl.device({
    name          = "logi-m240-mouse",
    sensitivity   = -0.35,
    accel_profile = "flat",
})

-- Built-in Touchpad: higher sensitivity
hl.device({
    name        = "ven_04f3:00-04f3:31d1-touchpad",
    sensitivity = 0.1,
})

hl.config({
    env = {
        "QML_IMPORT_PATH,/usr/lib/qt6/qml:/usr/local/lib/qt6/qml",
        "QML2_IMPORT_PATH,/usr/lib/qt6/qml:/usr/local/lib/qt6/qml",
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
    hl.exec_cmd("pgrep -u $(id -u) -x pipewire >/dev/null || pipewire")
    hl.exec_cmd("pgrep -u $(id -u) -f xps9350-v4l2-relay >/dev/null || /home/theo/.local/bin/xps9350-v4l2-relay /dev/video42")
    hl.exec_cmd("pgrep -u $(id -u) -x thunar >/dev/null || thunar --daemon")
end)

-- Dell XPS 13 Copilot key triggers Antigravity
hl.bind("F23", hl.dsp.exec_cmd("foot -T 'Antigravity' -e agy --dangerously-skip-permissions"))
hl.bind("SUPER + SHIFT + F23", hl.dsp.exec_cmd("foot -T 'Antigravity' -e agy --dangerously-skip-permissions"))
hl.bind("code:201", hl.dsp.exec_cmd("foot -e agy"))
