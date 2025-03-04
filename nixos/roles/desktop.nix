{
  pkgs,
  inputs,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      # BeatSaberModManager
      monado
      monado-vulkan-layers
    ];
  };

  programs.envision = {
    enable = true;
    openFirewall = true;
  };
}
