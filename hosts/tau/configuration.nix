{
  lib,
  pkgs,
  hostName,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default

    ./hardware-configuration.nix
    ./disk-config.nix
    ./secrets.nix
  ];

  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.stateVersion = "25.05";

    boot.loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    networking.hostName = hostName;

    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q"
    ];

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale-key.path;
      authKeyParameters.ephemeral = false;
      extraUpFlags = [
        "--advertise-tags=tag:nix"
        "--ssh"
      ];
    };

    services.adguardhome = {
      enable = true;
      settings = {
        mutableSettings = false;
        users = [
          {
            name = "admin";
            password = "@admin-password@";
          }
        ];
        dns = {
          upstream_dns = [
            "9.9.9.9#dns.quad9.net"
          ];
        };
      };
    };

    systemd.services.adguardhome.serviceConfig.ExecStartPre =
      "+${lib.getExe pkgs.replace-secret} @admin-password@ ${config.age.secrets.admin-password.path} /var/lib/AdGuardHome/AdGuardHome.yaml";

  };
}
