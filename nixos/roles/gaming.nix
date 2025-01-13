{
  pkgs,
  inputs,
  ...
}: let
  bizhawk =
    import (pkgs.fetchFromGitHub {
      owner = "TASEmulators";
      repo = "BizHawk";
      rev = "2.8";
      sha256 = "sha256-KXe69svPIIFaXgT9t+02pwdQ6WWqdqgUdtaE2S4/YxA=";
    }) {
      inherit pkgs;
    };
in {
  # boot.initrd.kernelModules = ["usbhid" "joydev" "xpad"];
  environment.systemPackages = with pkgs; [
    # archipelago
    bizhawk
    # https://github.com/TASEmulators/BizHawk?tab=readme-ov-file#nixnixos
  ];
}
