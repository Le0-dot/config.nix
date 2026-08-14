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

      den.aspects.nu.adguardhome
      den.aspects.nu.audiobookshelf
      den.aspects.nu.baikal
      den.aspects.nu.bentopdf
      den.aspects.nu.homeassistant
      den.aspects.nu.immich
      den.aspects.nu.jellyfin
      den.aspects.nu.jellyseerr
      den.aspects.nu.komga
      den.aspects.nu.ntfy
      den.aspects.nu.paperless-ngx
      den.aspects.nu.prowlarr
      den.aspects.nu.radarr
      den.aspects.nu.sonarr
      den.aspects.nu.transmission
    ];

    disk =
      let
        root-disk = "/dev/disk/by-id/nvme-Lexar_SSD_NM620_512GB_QFB155R004190P110W";
        data-disk-1 = "/dev/disk/by-id/nvme-ADATA_LEGEND_900_4N4221121212";
        data-disk-2 = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2516E9B84F3A";
        backup-disk = "/dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WMC4N0DDEXJ2";

        data-mount-options = [
          "noatime"
          "compress=zstd"
        ];
      in
      {
        main = {
          type = "disk";
          device = root-disk;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "1G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "defaults" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    root = {
                      mountpoint = "/";
                      mountOptions = [ "noatime" ];
                    };
                    nix = {
                      mountpoint = "/nix/store";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
        data = {
          type = "disk";
          device = data-disk-1;
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "-m raid1"
              "-d raid1"
              data-disk-2
            ];
            subvolumes = {
              "downloads/active" = {
                mountpoint = "/srv/downloads";
                mountOptions = data-mount-options;
              };
              "movies/active" = {
                mountpoint = "/srv/movies";
                mountOptions = data-mount-options;
              };
              "shows/active" = {
                mountpoint = "/srv/shows";
                mountOptions = data-mount-options;
              };
              "anime/active" = {
                mountpoint = "/srv/anime";
                mountOptions = data-mount-options;
              };
              "youtube/active" = {
                mountpoint = "/srv/youtube";
                mountOptions = data-mount-options;
              };
              "audiobooks/active" = {
                mountpoint = "/srv/audiobooks";
                mountOptions = data-mount-options;
              };
              "books/active" = {
                mountpoint = "/srv/books";
                mountOptions = data-mount-options;
              };
              "comics/active" = {
                mountpoint = "/srv/comics";
                mountOptions = data-mount-options;
              };
              "photos/active" = {
                mountpoint = "/srv/photos";
                mountOptions = data-mount-options;
              };
              "documents/active" = {
                mountpoint = "/srv/documents";
                mountOptions = data-mount-options;
              };
              "game-saves/active" = {
                mountpoint = "/srv/game-saves";
                mountOptions = data-mount-options;
              };
            };
          };
        };
        backup = {
          type = "disk";
          device = backup-disk;
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
          };
        };
      };

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

        services.btr-backup = {
          enable = true;
          config = {
            containers = {
              enable = true;
              device = config.disko.devices.disk.main.content.partitions.root.device;
              chdir = "containers";

              snapshot = {
                enable = true;
                onCalendar = "daily";
              };

              upload = {
                enable = true;
                onCalendar = "weekly";
                destinationDevice = config.disko.devices.disk.backup.device;
              };

              remove = {
                enable = true;
                onCalendar = "monthly";
                keepLatest = 30;
              };
            };

            data = {
              enable = true;
              device = config.disko.devices.disk.data.device;
              exclude = [ "downloads" ];

              snapshot = {
                enable = true;
                onCalendar = "daily";
              };

              upload = {
                enable = true;
                onCalendar = "weekly";
                destinationDevice = config.disko.devices.disk.backup.device;
              };

              remove = {
                enable = true;
                onCalendar = "monthly";
                keepLatest = 30;
              };
            };
          };
        };

        systemd.services =
          let
            ntfyTopic = "http://localhost:8090/backup";
          in
          {
            containers-snapshot-success-notify = {
              description = "Notify on successful containers snapshot";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Containers: created snapshots" \
                  -H "Priority: low" \
                  -H "Tags: white_check_mark" \
                  -d 'Successfully created snapshots for containers' \
                  ${ntfyTopic}
              '';
            };
            containers-snapshot-failure-notify = {
              description = "Notify on failed containers snapshot";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Containers: failed to create snapshots" \
                  -H "Priority: high" \
                  -H "Tags: warning" \
                  -d 'Failed to create snapshots for containers' \
                  ${ntfyTopic}
              '';
            };
            containers-snapshot = {
              onSuccess = [ "containers-snapshot-success-notify.service" ];
              onFailure = [ "containers-snapshot-failure-notify.service" ];
            };
            containers-upload-success-notify = {
              description = "Notify on successful containers snapshot upload";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Containers: uploaded" \
                  -H "Priority: low" \
                  -H "Tags: outbox_tray,inbox_tray" \
                  -d 'Successfully uploaded snapshots for containers' \
                  ${ntfyTopic}
              '';
            };
            containers-upload-failure-notify = {
              description = "Notify on failed containers snapshot upload";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Containers: failed to upload" \
                  -H "Priority: high" \
                  -H "Tags: warning,outbox_tray,inbox_tray" \
                  -d 'Failed to upload snapshots for containers' \
                  ${ntfyTopic}
              '';
            };
            containers-upload = {
              onSuccess = [ "containers-upload-success-notify.service" ];
              onFailure = [ "containers-upload-failure-notify.service" ];
            };
            containers-remove-success-notify = {
              description = "Notify on successful containers snapshot removal";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Containers: removed" \
                  -H "Priority: low" \
                  -H "Tags: wastebasket" \
                  -d 'Successfully removed snapshots for containers' \
                  ${ntfyTopic}
              '';
            };
            containers-remove-failure-notify = {
              description = "Notify on failed containers snapshot removal";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Containers: failed to remove" \
                  -H "Priority: high" \
                  -H "Tags: warning,wastebasket" \
                  -d 'Failed to remove snapshots for containers' \
                  ${ntfyTopic}
              '';
            };
            containers-remove = {
              onSuccess = [ "containers-remove-success-notify.service" ];
              onFailure = [ "containers-remove-failure-notify.service" ];
            };

            data-snapshot-success-notify = {
              description = "Notify on successful data snapshot";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Data: created snapshots" \
                  -H "Priority: low" \
                  -H "Tags: white_check_mark" \
                  -d 'Successfully created snapshots for data' \
                  ${ntfyTopic}
              '';
            };
            data-snapshot-failure-notify = {
              description = "Notify on failed data snapshot";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Data: failed to create snapshots" \
                  -H "Priority: high" \
                  -H "Tags: warning" \
                  -d 'Failed to create snapshots for data' \
                  ${ntfyTopic}
              '';
            };
            data-snapshot = {
              onSuccess = [ "data-snapshot-success-notify.service" ];
              onFailure = [ "data-snapshot-failure-notify.service" ];
            };
            data-upload-success-notify = {
              description = "Notify on successful data snapshot upload";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Data: uploaded" \
                  -H "Priority: low" \
                  -H "Tags: outbox_tray,inbox_tray" \
                  -d 'Successfully uploaded snapshots for data' \
                  ${ntfyTopic}
              '';
            };
            data-upload-failure-notify = {
              description = "Notify on failed data snapshot upload";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Data: failed to upload" \
                  -H "Priority: high" \
                  -H "Tags: warning,outbox_tray,inbox_tray" \
                  -d 'Failed to upload snapshots for data' \
                  ${ntfyTopic}
              '';
            };
            data-upload = {
              onSuccess = [ "data-upload-success-notify.service" ];
              onFailure = [ "data-upload-failure-notify.service" ];
            };
            data-remove-success-notify = {
              description = "Notify on successful data snapshot removal";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Data: removed" \
                  -H "Priority: low" \
                  -H "Tags: wastebasket" \
                  -d 'Successfully removed snapshots for data' \
                  ${ntfyTopic}
              '';
            };
            data-remove-failure-notify = {
              description = "Notify on failed data snapshot removal";
              path = [ pkgs.curl ];
              script = ''
                curl \
                  -H "Title: Data: failed to remove" \
                  -H "Priority: high" \
                  -H "Tags: warning,wastebasket" \
                  -d 'Failed to remove snapshots for data' \
                  ${ntfyTopic}
              '';
            };
            data-remove = {
              onSuccess = [ "data-remove-success-notify.service" ];
              onFailure = [ "data-remove-failure-notify.service" ];
            };
          };
      };
    checks =
      { pkgs, ... }:
      let
        config = self.nixosConfigurations.nu.config;
      in
      {
        assert-nu-build = config.system.build.toplevel;
      };
  };
}
