-- CachyOS desktop host-specific Hyprland overrides.
-- Run `hyprctl monitors` on the desktop to set your exact output/mode if needed.

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Start thunar daemon (PipeWire and D-Bus activation are managed by systemd on CachyOS)
hl.on("hyprland.start", function()
    hl.exec_cmd("pgrep -u $(id -u) -x thunar >/dev/null || thunar --daemon")
end)
