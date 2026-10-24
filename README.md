# comfyui-remote

Run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) on a Linux GPU server you
can reach over SSH and use it in your local browser with one command.
`comfyui-remote` starts ComfyUI as an on-demand systemd user service on the
server, opens a private SSH tunnel and launches the browser.
`comfyui-remote stop` shuts it down and releases the GPU memory.

ComfyUI listens only on loopback at both ends of the tunnel, so nothing is
exposed on the network and no extra authentication is needed beyond your SSH key.

## Requirements

- **Client** (macOS or Linux): Python 3.8 or later and OpenSSH.
- **Server** (Linux with systemd): a working ComfyUI install, `curl`, and SSH
  access with a key (the client runs SSH in batch mode, so it can't prompt for
  a password).

## Install

On the server:

```sh
git clone https://github.com/jnersn/comfyui-remote.git
comfyui-remote/server/install.sh
```

This installs the `comfyui` wrapper into `~/.local/bin`, the `comfyui.service`
user unit, and a commented `~/.config/comfyui-remote/server.env`. By default the
service runs `~/ComfyUI/main.py` with `~/ComfyUI/.venv/bin/python`. If your
install lives elsewhere, set `COMFYUI_DIR` (and `COMFYUI_PYTHON` if the Python
isn't in a `.venv` there) in `server.env`. `COMFYUI_ARGS` passes extra ComfyUI
arguments, for example a models directory on another disk; quote values that
contain spaces.

To keep ComfyUI running after you close the SSH session, enable lingering for
your user once: `sudo loginctl enable-linger $USER`.

On the client:

```sh
git clone https://github.com/jnersn/comfyui-remote.git
comfyui-remote/install.sh            # links ~/.local/bin/comfyui-remote
```

`install.sh comfyui` links it under a shorter name instead. Make sure
`~/.local/bin` is on your `PATH`. Then name your server, using a host or an
alias from `~/.ssh/config`:

```sh
mkdir -p ~/.config/comfyui-remote
echo 'COMFYUI_REMOTE_HOST=gpu-box' > ~/.config/comfyui-remote/config
```

## Usage

```sh
comfyui-remote                # start the service, open the tunnel and the browser
comfyui-remote --no-browser   # the same, but only print the address
comfyui-remote status         # service status on the server
comfyui-remote logs           # follow the ComfyUI log; Ctrl-C stops following
comfyui-remote restart        # restart the service, e.g. after installing custom nodes
comfyui-remote stop           # stop the service, free the GPU, close the tunnel
```

ComfyUI is at `http://127.0.0.1:8188`. It keeps running when you close the
browser tab or the terminal, and it doesn't start at boot. Run `stop` when you're
done to free the GPU for other work.

On the server itself, `comfyui start|stop|restart|status|logs` does the same
without the tunnel.

## Configuration

Client settings go in `~/.config/comfyui-remote/config` as `KEY=value` lines, or
in the environment, which takes precedence:

| Setting | Default | What |
|---|---|---|
| `COMFYUI_REMOTE_HOST` | (required) | SSH host or `~/.ssh/config` alias of the server |
| `COMFYUI_REMOTE_PORT` | `8188` | ComfyUI port on the server |
| `COMFYUI_REMOTE_LOCAL_PORT` | same as the server port | Local end of the tunnel |
| `COMFYUI_REMOTE_COMMAND` | `.local/bin/comfyui` | Server-side wrapper, relative to the remote home |

Server settings go in `~/.config/comfyui-remote/server.env` (systemd
`EnvironmentFile` syntax):

| Setting | Default | What |
|---|---|---|
| `COMFYUI_DIR` | `~/ComfyUI` | ComfyUI checkout |
| `COMFYUI_PYTHON` | `$COMFYUI_DIR/.venv/bin/python` | Python that runs ComfyUI |
| `COMFYUI_PORT` | `8188` | Port on the server's loopback |
| `COMFYUI_ARGS` | (none) | Extra ComfyUI arguments |
| any other variable | | Passed to ComfyUI, e.g. `HF_HOME`, `TORCH_HOME` |

For anything else, such as waiting for a data disk to mount, add a drop-in with
`systemctl --user edit comfyui.service`.

To use several servers, set `COMFYUI_REMOTE_HOST` (and a different
`COMFYUI_REMOTE_LOCAL_PORT`) per command or with a shell alias. Each host and
port pair gets its own tunnel.

## Troubleshooting

- **"Could not open the SSH tunnel"**: something else is using the local port.
  Pick another with `COMFYUI_REMOTE_LOCAL_PORT`.
- **"ComfyUI did not become ready"**: the last log lines are printed. Check
  `COMFYUI_DIR` and `COMFYUI_PYTHON`, or run `comfyui-remote logs`.
- **SSH asks for a password or fails**: check that `ssh <host> true` works
  without prompting.

## License

MIT. See [LICENSE](LICENSE).
