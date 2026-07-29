{
  den.aspects.server = {
    nixos = { ... }: {
      environment.enableAllTerminfo = true;
      services.openssh.enable = true;
      users = {
        mutableUsers = false;
        users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q"
        ];
      };
    };
  };
}
