#!/bin/sh
set -euo pipefail

ip -4 addr flush dev "$INTERFACE"
exec udhcpc -i "$INTERFACE" -F "$(hostname)" -f
