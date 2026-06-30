{ den, inputs, ... }:
let
  customLib = import ../../lib/default.nix { };
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
        ../_hardware/nu-hardware.nix
        ../_hardware/nu-disk.nix
        ../_secrets/nu.nix
        # backup and containers still at original location (moved in Stage F)
        ../../hosts/nu/backup.nix
        ../../hosts/nu/containers/audiobookshelf.nix
        ../../hosts/nu/containers/adguardhome.nix
        ../../hosts/nu/containers/baikal.nix
        ../../hosts/nu/containers/jellyfin.nix
        ../../hosts/nu/containers/komga.nix
        ../../hosts/nu/containers/paperless-ngx.nix
        ../../hosts/nu/containers/transmission.nix
        ../../hosts/nu/containers/prowlarr.nix
        ../../hosts/nu/containers/radarr.nix
        ../../hosts/nu/containers/sonarr.nix
        ../../hosts/nu/containers/jellyseerr.nix
        ../../hosts/nu/containers/immich.nix
        ../../hosts/nu/containers/homeassistant.nix
        ../../hosts/nu/containers/bentopdf.nix
        ../../hosts/nu/containers/ntfy.nix
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
