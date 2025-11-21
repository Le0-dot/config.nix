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

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "${hostName} server";
          "security" = "user";
          "server min protocol" = "SMB3";
          "unix password sync" = "yes";
          "passwd program" = "/usr/bin/passwd %u";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "use sendfile" = "yes";
          "aio read size" = 1;
          "aio write size" = 1;
        };
        "public" = {
          "path" = "/tmp";
          "public" = "no";
          "browseable" = "yes";
          "read only" = "yes";
          "force user" = "root";
        };
      };
    };

    services.samba-wsdd.enable = true;

    system.activationScripts.samba-users.text = builtins.concatStringsSep "\n" (
      builtins.map (user: "/run/current-system/sw/bin/smbpasswd -sa ${user.name} << EOF\n\n\nEOF") (
        builtins.filter (user: user.isNormalUser) (builtins.attrValues config.users.users)
      )
    );
  };
}
