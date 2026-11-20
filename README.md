# Dotfiles (Void Laptop ↔ CachyOS Desktop)

Managed with **Git + GNU Stow** using a shared base and per-host overrides.

## Layout
- `bash/` — Shared `.bashrc`, `foot`, `btop`, `micro` (`fastfetch` is excluded via `.gitignore`).
- `caelestia/` — Shared Caelestia `shell.json`, `hypr-vars.lua`, and `hypr-user.lua` (loads optional `hypr-host.lua`).
- `quickshell-caelestia/` — Custom `~/.config/quickshell/caelestia` QML shell config.
- `system/keyd/default.conf` — Shared macOS-style `keyd` modifier layout (`/etc/keyd/default.conf`).
- `hosts/void-laptop/` — Dell XPS 13 9350 / Void-specific `hypr-host.lua` and `.bashrc.local`.
- `hosts/cachyos-desktop/` — CachyOS desktop `hypr-host.lua` and `.bashrc.local`.

## Setup on CachyOS Desktop
```bash
git clone https://github.com/23knightst813/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh cachyos-desktop
```

After logging into Hyprland on your desktop, run `hyprctl monitors` and update `hosts/cachyos-desktop/.config/caelestia/hypr-host.lua` with your desktop monitor output/mode.

## Daily Sync
```bash
# Push changes from either machine:
cd ~/dotfiles && git add -A && git commit -m "update config" && git push

# Pull changes on the other machine:
cd ~/dotfiles && git pull
hyprctl reload && caelestia shell -r -d
```
