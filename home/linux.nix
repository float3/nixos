{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nix-index
  ];

  programs = {
    nix-index = {
      enable = true;
      # The fish integration is not set here: programs.fish is no longer
      # enabled in this profile, and the flake's fish config defines
      # fish_command_not_found itself.
      enableFishIntegration = false;
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
