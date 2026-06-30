# Shared NixOS server base config (tau + nu).
# stateVersion comes from den.default, hostname from den.batteries.hostname.
{ den, ... }:
{
  den.aspects.server-base = {
    nixos = { ... }: {
      system.stateVersion = "25.05";

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.gc.automatic = true;

      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

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
