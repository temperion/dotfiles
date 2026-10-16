#!/usr/bin/env bash
# Pinta o ARGB (fans e cooler, pela placa-mae) com a cor de destaque do tema 43pr.
# Chamado pelo theme.py a cada troca de tema e no login (autostart do Hyprland).

# Velocidade da respiracao: 0 = mais lenta, 100 = mais rapida.
speed=20

f="$HOME/.cache/43pr/openrgb-color"
[[ -r "$f" ]] || exit 0
hex=$(tr -dc '0-9a-fA-F' < "$f" | head -c 6)
[[ ${#hex} -eq 6 ]] || exit 0

# Cores pastel ficam desbotadas nos LEDs: mantem o matiz e deixa a cor viva.
hex=$(python3 -c '
import colorsys, sys
h = sys.argv[1]
r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
H, S, V = colorsys.rgb_to_hsv(r, g, b)
if S > 0.15:
    S = max(S, 0.85)
r, g, b = colorsys.hsv_to_rgb(H, S, 1.0)
print("%02X%02X%02X" % (round(r * 255), round(g * 255), round(b * 255)))
' "$hex") || exit 0

# Roda em segundo plano (o OpenRGB demora alguns segundos) e uma vez por vez.
log="$HOME/.cache/43pr/rgb-sync.log"
(
    flock -w 30 9 || { echo "$(date +%T) outra copia travada, desisti"; exit 0; }
    echo "$(date +%T) tema=$(cat "$f") -> led=$hex"

    # Espera o servidor do OpenRGB (iniciado no login) responder; com ele no ar,
    # o comando so repassa a cor, sem redetectar o hardware a cada chamada.
    for _ in $(seq 20); do
        (exec 3<>/dev/tcp/127.0.0.1/6742) 2>/dev/null && break
        sleep 1
    done

    for tentativa in 1 2 3; do
        openrgb --device 0 --mode breathing --speed "$speed" --color "$hex"
        rc=$?
        echo "$(date +%T) tentativa $tentativa: openrgb saiu com codigo $rc"
        [[ $rc -eq 0 ]] && break
        sleep 2
    done
) 9>"${XDG_RUNTIME_DIR:-/tmp}/rgb-sync.lock" >"$log" 2>&1 </dev/null &
disown
