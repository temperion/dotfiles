#!/bin/bash
# Wrapper do underclock da GPU. O script real e a regra de sudoers ficam no sistema:
#   /usr/local/bin/gpu-underclock.sh  +  sudoers NOPASSWD para ele
[ -x /usr/local/bin/gpu-underclock.sh ] || exit 0
sleep 5
xhost +SI:localuser:root >/dev/null
sudo -n /usr/local/bin/gpu-underclock.sh
xhost -SI:localuser:root >/dev/null
