-- Caelestia shared user config (Void laptop + CachyOS desktop).
-- Loaded after all Caelestia defaults, so anything here overrides them.

local home = os.getenv("HOME")

hl.env("PATH", home .. "/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
hl.env("TERMINAL", "foot")

hl.config({
    input = {
        kb_layout = "gb",
        natural_scroll = false,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Regional screenshot to clipboard (Ctrl + Shift + 4 / physical Left Ctrl + Shift + 4)
hl.bind("SUPER + SHIFT + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("CTRL + SHIFT + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- macOS-style extras (physical Left Ctrl = Command via keyd) ---------------------------

-- Cmd+Space opens the launcher.
hl.bind("SUPER + Space", hl.dsp.global("caelestia:launcher"), { release = true })

-- Cmd+H / Cmd+M hide or minimise the active window into a special workspace.
hl.bind("SUPER + H", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
hl.bind("SUPER + M", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
hl.bind("SUPER + ALT + H", hl.dsp.workspace.toggle_special("minimized"))

-- Caelestia's shell restart binds use R, which keyd sends to the focused app
-- (Cmd+R), so keep equivalent bindings on a free key.
hl.bind("CTRL + SUPER + SHIFT + F12", hl.dsp.exec_cmd("caelestia shell -k"), { release = true })
hl.bind("CTRL + SUPER + ALT + F12", hl.dsp.exec_cmd("caelestia shell -r -d"), { release = true })

-- Load machine-specific overrides (~/.config/caelestia/hypr-host.lua) if present.
pcall(require, "hypr-host")
