#!/bin/sh
# Link the client into ~/.local/bin (must be on PATH). Pass a name to link it under another name.
set -eu
here=$(cd -- "$(dirname -- "$0")" && pwd)
name=${1:-comfyui-remote}
mkdir -p "$HOME/.local/bin"
ln -sfn "$here/comfyui-remote" "$HOME/.local/bin/$name"
echo "linked ~/.local/bin/$name -> $here/comfyui-remote"
