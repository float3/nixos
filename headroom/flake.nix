{
  description = "Headroom CLI environment for Codex";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      python = pkgs.python313;
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_24
          python
          uv
        ];

        shellHook = ''
          if [ -f "$PWD/headroom/flake.nix" ]; then
            export HEADROOM_DIR="$PWD/headroom"
          else
            export HEADROOM_DIR="$PWD"
          fi

          export HEADROOM_VENV="$HEADROOM_DIR/.venv"

          if [ ! -x "$HEADROOM_VENV/bin/headroom" ] || [ -n "''${HEADROOM_UPDATE:-}" ]; then
            echo "Installing headroom-ai[all] into $HEADROOM_VENV"
            uv venv --python ${python}/bin/python "$HEADROOM_VENV"
            uv pip install --python "$HEADROOM_VENV/bin/python" "headroom-ai[all]"
          fi

          export PATH="$HEADROOM_VENV/bin:$PATH"
          echo "Headroom ready: $(headroom --version 2>/dev/null || echo headroom CLI installed)"
        '';
      };
    });
  };
}
