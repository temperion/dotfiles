#!/usr/bin/env bash
# Monta o Google Drive no login via rclone:
#   ~/GoogleDrive                -> Meu Drive (remote "gdrive")
#   ~/GoogleDrive-Compartilhados -> todos os Drives compartilhados (remote "AllDrives")

mount_one() {
    local remote="$1" dir="$2"
    mkdir -p "$dir"
    mountpoint -q "$dir" && return 0   # ja montado
    rclone mount "$remote" "$dir" --vfs-cache-mode full --daemon
}

# Espera a internet/Google responderem (ate ~60 s) antes de montar
for _ in $(seq 30); do
    rclone about gdrive: >/dev/null 2>&1 && break
    sleep 2
done

mount_one gdrive: "$HOME/GoogleDrive"
mount_one AllDrives: "$HOME/GoogleDrive-Compartilhados"
