{ den, inputs, ... }:
let
  customLib = import ../../_packages/lib.nix { };
in
{
  den.hosts.x86_64-linux.nu = { };

  den.aspects.nu = {
    includes = [
      den.aspects.server-base
      den.aspects.tailscale
      den.aspects.samba
    ];
    nixos = { config, pkgs, ... }: {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.agenix.nixosModules.default
        inputs.quadlet-nix.nixosModules.quadlet
        inputs.btr-backup.nixosModules.btr-backup
        ./_hardware.nix
        ./_disk.nix
        ./_secrets.nix
        ../../_containers/backup.nix
        ../../_containers/audiobookshelf.nix
        ../../_containers/adguardhome.nix
        ../../_containers/baikal.nix
        ../../_containers/jellyfin.nix
        ../../_containers/komga.nix
        ../../_containers/paperless-ngx.nix
        ../../_containers/transmission.nix
        ../../_containers/prowlarr.nix
        ../../_containers/radarr.nix
        ../../_containers/sonarr.nix
        ../../_containers/jellyseerr.nix
        ../../_containers/immich.nix
        ../../_containers/homeassistant.nix
        ../../_containers/bentopdf.nix
        ../../_containers/ntfy.nix
      ];

      # Provide flake.lib for container modules that use btrfsVolume/mountVolume
      _module.args.flake = { lib = customLib; };

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
        services.enable = true;
      };
    };
  };
}
