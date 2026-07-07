# Headroom For Codex

This flake provides the Python `headroom` CLI in an isolated virtualenv for
NixOS.

Enter the environment:

```sh
nix develop ./headroom
```

The first shell entry creates `headroom/.venv` and installs:

```sh
uv pip install "headroom-ai[all]"
```

Then use the CLI from inside that shell:

```sh
headroom doctor
headroom wrap codex
headroom proxy --port 8787
headroom perf
headroom dashboard
```

Force an update:

```sh
HEADROOM_UPDATE=1 nix develop ./headroom
```
