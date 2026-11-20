#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="${1:-}"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
SHARED_PACKAGES=(bash caelestia quickshell-caelestia)

usage() {
    echo "Usage: $0 <void-laptop|cachyos-desktop>"
    exit 1
}

[[ -z "$HOST" || ! -d "$DOTFILES_DIR/hosts/$HOST" ]] && usage

detect_distro() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

install_deps() {
    local distro="$1"
    local missing=()
    command -v git >/dev/null 2>&1 || missing+=(git)
    command -v stow >/dev/null 2>&1 || missing+=(stow)
    command -v keyd >/dev/null 2>&1 || missing+=(keyd)

    if (( ${#missing[@]} == 0 )); then
        return 0
    fi

    echo "Installing missing packages (${missing[*]}) for $distro..."
    case "$distro" in
        void)
            sudo xbps-install -Sy "${missing[@]}"
            ;;
        cachyos|arch)
            sudo pacman -S --needed --noconfirm "${missing[@]}"
            ;;
        *)
            echo "Unsupported distro '$distro'. Please install: ${missing[*]}"
            exit 1
            ;;
    esac
}

backup_target() {
    local rel="$1"
    local target="$HOME/$rel"

    # Skip if nothing exists and not a broken symlink
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return 0
    fi

    # Skip if already symlinked inside DOTFILES_DIR
    if [[ -L "$target" ]]; then
        local resolved
        resolved="$(readlink -f "$target" 2>/dev/null || true)"
        if [[ "$resolved" == "$DOTFILES_DIR"* ]]; then
            return 0
        fi
    fi

    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
    echo "Backed up $target -> $BACKUP_DIR/$rel"
}

DISTRO="$(detect_distro)"
install_deps "$DISTRO"

# Ensure mixed directories exist before stowing so generated files (foot/colors.ini,
# btop/themes, caelestia/monitors) and excluded dirs (fastfetch) stay untouched.
mkdir -p \
    "$HOME/.config/btop" \
    "$HOME/.config/caelestia" \
    "$HOME/.config/foot" \
    "$HOME/.config/micro" \
    "$HOME/.config/quickshell"

TARGETS=(
    ".bashrc"
    ".bashrc.local"
    ".config/btop/btop.conf"
    ".config/caelestia/shell.json"
    ".config/caelestia/hypr-vars.lua"
    ".config/caelestia/hypr-user.lua"
    ".config/caelestia/hypr-host.lua"
    ".config/foot/foot.ini"
    ".config/foot/update-colors.sh"
    ".config/micro/bindings.json"
    ".config/quickshell/caelestia"
)

for rel in "${TARGETS[@]}"; do
    backup_target "$rel"
done

echo "Stowing shared packages..."
stow -R -v -d "$DOTFILES_DIR" -t "$HOME" "${SHARED_PACKAGES[@]}"

echo "Stowing host package: $HOST..."
stow -R -v -d "$DOTFILES_DIR/hosts" -t "$HOME" "$HOST"

if [[ -f "$DOTFILES_DIR/system/keyd/default.conf" ]]; then
    echo "Installing /etc/keyd/default.conf..."
    sudo install -Dm644 "$DOTFILES_DIR/system/keyd/default.conf" /etc/keyd/default.conf
    case "$DISTRO" in
        void)
            if [[ -L /var/service/keyd ]]; then
                sudo sv restart keyd || true
            else
                echo "Note: enable keyd service on Void with: sudo ln -s /etc/sv/keyd /var/service/"
            fi
            ;;
        cachyos|arch)
            sudo systemctl enable --now keyd
            sudo systemctl reload keyd || sudo systemctl restart keyd
            ;;
    esac
fi

if [[ "$DISTRO" == "cachyos" || "$DISTRO" == "arch" ]]; then
    if [[ ! -d "$HOME/.local/share/caelestia" || ! -e "$HOME/.config/hypr" ]]; then
        echo ""
        echo "Reminder: Ensure Caelestia dots are installed on CachyOS (~/.local/share/caelestia and ~/.config/hypr)."
    fi
fi

echo "Done! Reload Hyprland/Caelestia with: hyprctl reload && caelestia shell -r -d"
