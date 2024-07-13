{
  pkgs,
  inputs,
  ...
}: {
  # boot.initrd.kernelModules = ["usbhid" "joydev" "xpad"];
  environment.systemPackages = with pkgs; [
    xboxdrv
  ];
}
