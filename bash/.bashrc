# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias agy='agy --dangerously-skip-permissions'
alias refresh='source ~/.bashrc'
PS1='[\u@\h \W]\$ '

# Local user binaries
export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Run fastfetch on interactive terminal start with dynamic caelestia accent color
if command -v fastfetch >/dev/null 2>&1; then
    if [[ -f "$HOME/.local/state/caelestia/scheme.json" ]]; then
        _ff_rgb=$(python3 -c '
import json, os
with open(os.path.expanduser("~/.local/state/caelestia/scheme.json")) as f:
    h = json.load(f)["colours"]["primary"].lstrip("#")
print(f"38;2;{int(h[0:2],16)};{int(h[2:4],16)};{int(h[4:6],16)}")
' 2>/dev/null)
        _ff_args=()
        (( $(tput cols 2>/dev/null || echo 80) < 80 )) && _ff_args+=(--structure none)
        if [[ -n "$_ff_rgb" ]]; then
            fastfetch --logo-color-1 "$_ff_rgb" "${_ff_args[@]}"
        else
            fastfetch "${_ff_args[@]}"
        fi
        unset _ff_rgb _ff_args
    else
        fastfetch
    fi
fi

# Sync foot terminal colors with caelestia scheme
[ -x "$HOME/.config/foot/update-colors.sh" ] && "$HOME/.config/foot/update-colors.sh"

# Machine-local overrides (not synced across hosts)
[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
