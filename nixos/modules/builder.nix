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

    # FIXME: both keys below have been lowercased at some point, which corrupts
    # the base64 blob ("aaaac3nzac1lzdi1nte5" should read "AAAAC3NzaC1lZDI1NTE5").
    # sshd rejects them, so nixremote logins and distributed builds cannot work
    # until the original public keys are pasted back in verbatim.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaifmejhgotkxtw0o8kyteyskxu1i4qabhmjnhmi4uo83+ root@workstation"
      "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaiiajs2amapfu0qnfykzg99npn71xzjrc0crvjhnp9peb root@laptop"
    ];
  };
}
