#!/bin/sh
# Install the server side for the current user: the comfyui wrapper and the systemd user service.
# Safe to re-run; an existing server.env is left alone.
set -eu
here=$(cd -- "$(dirname -- "$0")" && pwd)
config="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$HOME/.local/bin" "$config/systemd/user" "$config/comfyui-remote"
install -m 0755 "$here/comfyui" "$HOME/.local/bin/comfyui"
install -m 0644 "$here/comfyui.service" "$config/systemd/user/comfyui.service"
if [ ! -e "$config/comfyui-remote/server.env" ]; then
  install -m 0600 "$here/server.env.example" "$config/comfyui-remote/server.env"
  echo "created $config/comfyui-remote/server.env (edit it to match your ComfyUI install)"
fi
systemctl --user daemon-reload
echo "installed ~/.local/bin/comfyui and the comfyui.service user unit"
if [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != yes ]; then
  echo "To keep ComfyUI running after you log out, run: sudo loginctl enable-linger $USER"
fi
