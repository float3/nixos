{
  pkgs,
  inputs,
  ...
}: {
  boot.initrd.kernelModules = ["usbhid" "joydev" "xpad"];
}
