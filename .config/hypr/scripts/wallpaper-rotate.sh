#!/usr/bin/env bash
# Troca o wallpaper por uma imagem aleatoria da pasta a cada N segundos (padrao: 600 = 10 min).
# Usa o mesmo comando do seletor (Super+W): aplica com awww e recalcula as cores com o theme.py.
# Uso: wallpaper-rotate.sh [segundos]

dir="$HOME/Pictures/Wallpapers"
interval="${1:-600}"
apply="$HOME/.config/quickshell/hyprquickpaper/commands.sh"

# So uma copia rodando por vez
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/wallpaper-rotate.lock"
flock -n 9 || exit 0

# Espera o awww-daemon subir
for _ in $(seq 30); do awww query >/dev/null 2>&1 && break; sleep 1; done

last=""
while true; do
    sleep "$interval"
    mapfile -t imgs < <(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \))
    n=${#imgs[@]}
    (( n )) || continue
    img="${imgs[RANDOM % n]}"
    while (( n > 1 )) && [[ "$img" == "$last" ]]; do img="${imgs[RANDOM % n]}"; done
    "$apply" "$img" && last="$img"
done
