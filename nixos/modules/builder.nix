{config, ...}: {
  nix = {
    settings.trusted-users = ["nixremote"];
    sshServe = {
      enable = true;
      write = true;
      keys = config.users.users.nixremote.openssh.authorizedKeys.keys;
    };
  };

  users.users.nixremote = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaifmejhgotkxtw0o8kyteyskxu1i4qabhmjnhmi4uo83+ root@workstation"
      "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaiiajs2amapfu0qnfykzg99npn71xzjrc0crvjhnp9peb root@laptop"
    ];
  };
}
