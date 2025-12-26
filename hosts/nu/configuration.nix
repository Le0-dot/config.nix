{
  pkgs,
  flake,
  inputs,
  config,
  hostName,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.quadlet-nix.nixosModules.quadlet

    flake.nixosModules.tailscale
    flake.nixosModules.samba

    ./hardware-configuration.nix
    ./disk-config.nix
    ./secrets.nix

    ./containers/audiobookshelf.nix
    ./containers/adguardhome.nix
    ./containers/baikal.nix
    ./containers/jellyfin.nix
    ./containers/komga.nix
    ./containers/paperless-ngx.nix
  ];

  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.stateVersion = "25.05";

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    networking.hostName = hostName;

    services.openssh.enable = true;

    users = {
      mutableUsers = false;
      users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q"
      ];
    };

    environment.systemPackages = [
      pkgs.neovim
      pkgs.curl
      pkgs.jq
    ];

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale-key.path;
      authKeyParameters.ephemeral = false;
      extraUpFlags = [
        "--advertise-tags=tag:nix"
        "--ssh"
      ];
      services = {
        enable = true;
        enablePods = true;
      };
    };
  };
}
