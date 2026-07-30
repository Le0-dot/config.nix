{
  den,
  self,
  inputs,
  ...
}:
{
  den.aspects.nu = {
    includes = [
      den.aspects.bootloader
      den.aspects.server
      den.aspects.tailscale
      den.aspects.samba

      den.aspects.server.containers.adguardhome
      den.aspects.server.containers.audiobookshelf
      den.aspects.server.containers.baikal
      den.aspects.server.containers.bentopdf
      den.aspects.server.containers.homeassistant
      den.aspects.server.containers.immich
      den.aspects.server.containers.jellyfin
      den.aspects.server.containers.jellyseerr
      den.aspects.server.containers.komga
      den.aspects.server.containers.ntfy
      den.aspects.server.containers.paperless-ngx
      den.aspects.server.containers.prowlarr
      den.aspects.server.containers.radarr
      den.aspects.server.containers.sonarr
      den.aspects.server.containers.transmission
    ];
    nixos = { config, pkgs, ... }: {
      imports = [
        inputs.btr-backup.nixosModules.btr-backup
        ./_hardware.nix
        ./_disk.nix
        ./_secrets.nix
        ./_backup.nix
      ];

      _module.args.flake = self;

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
