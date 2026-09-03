{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      a2jmidid
      alsa-utils
      android-tools
      blender
      btop
      # cargo
      # cargo-bundle-licenses
      # cargo-cache
      # cargo-expand
      cargo-edit
      # cargo-license
      cargo-update
      chrysalis
      code-cursor
      # clang
      # clang-tools
      # cmake
      # cmake-format
      cnping
      conda
      # corepack_latest
      dig
      # dotnet-aspnetcore_8
      # dotnet-runtime_8
      # dotnet-sdk_8
      # emscripten
      ffmpeg
      # gdb
      # ghidra
      gimp
      rustup
      # gnumake
      inetutils
      imhex
      nix-ld
      nix-index
      libreoffice
      mob
      # mono
      # msbuild
      # ninja
      # nodejs_23
      tldr
      traceroute
      tree
      # trunk
      # trunk-ng
      unityhub
      usbutils
      # ventoy-full
      vmpk
      vrc-get
      vscode
      wasm-pack
      wireguard-tools
      wireshark
      zip
      zola
    ];
  };

  users.users.${username}.extraGroups = [
    "docker"
  ];
}
