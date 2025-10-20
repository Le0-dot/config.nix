{ hostName, config, inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default

    ./hardware-configuration.nix
    ./disk-config.nix
    ./secrets.nix
  ];

  config = {
    system.stateVersion = "25.05";

    boot.loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    networking.hostName = hostName;

    services.openssh.enable = true;

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale-key.path;
      authKeyParameters.ephemeral = false;
      extraUpFlags = [ "--advertise-tags=tag:server" "--ssh" ];
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q"
    ];
  };
}
