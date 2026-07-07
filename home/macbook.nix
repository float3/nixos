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

  programs.ssh.settings = {
    workstation = {
      HostName = "workstation.local";
      User = "hill";
      IdentitiesOnly = true;
    };
    thinkcentre = {
      HostName = "thinkcentre.local";
      User = "hill";
      IdentitiesOnly = true;
    };
  };
}
