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
    nixos =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        imports = [
          inputs.nixpkgs.nixosModules.notDetected
          inputs.btr-backup.nixosModules.btr-backup
          ./_disk.nix
          ./_backup.nix
        ];

        hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "sdhci_pci"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;

        age.secrets = {
          tailscale-key.file = ../../../secrets/tailscale-key.age;
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
          services.enable = true;
        };
      };
  };
}
