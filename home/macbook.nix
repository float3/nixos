{pkgs, ...}: {
  home.packages = with pkgs; [
    coreutils
    curl
    findutils
    gnugrep
    gnused
    gnutar
    pinentry_mac
  ];

  programs.ssh.matchBlocks = {
    workstation = {
      hostname = "workstation.local";
      user = "hill";
      identitiesOnly = true;
    };
    thinkcentre = {
      hostname = "thinkcentre.local";
      user = "hill";
      identitiesOnly = true;
    };
  };
}
