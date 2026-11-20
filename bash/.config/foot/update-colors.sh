#!/usr/bin/env bash
SCHEME="$HOME/.local/state/caelestia/scheme.json"
OUT="$HOME/.config/foot/colors.ini"

[ -f "$SCHEME" ] || exit 0

python3 -c "
import json
with open('$SCHEME') as f:
    c = json.load(f)['colours']
with open('$OUT', 'w') as f:
    f.write(f'''[colors-dark]
alpha=0.92
background={c['surfaceContainer']}
foreground={c['onSurface']}
''')
"
