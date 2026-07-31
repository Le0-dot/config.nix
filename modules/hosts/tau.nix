{ den, inputs, ... }:
{
  den.aspects.tau = {
    includes = [
      den.aspects.bootloader
      den.aspects.server
      den.aspects.tailscale
      den.aspects.samba
    ];
    nixos =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        imports = [ inputs.nixpkgs.nixosModules.notDetected ];

        hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        disko.devices.disk.main = {
          type = "disk";
          device = "/dev/sda";
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
                  };
                };
              };
            };
          };
        };

        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

        age.secrets = {
          tailscale-key.file = ../../secrets/tailscale-key.age;
          le0-password.file = ../../secrets/le0-password.age;
          garage-rpc-secret.file = ../../secrets/garage-rpc-secret.age;
        };

        users.users.le0.isNormalUser = true;

        services.tailscale = {
          enable = true;
          authKeyFile = config.age.secrets.tailscale-key.path;
          authKeyParameters.ephemeral = false;
          extraUpFlags = [
            "--advertise-tags=tag:nix"
            "--ssh"
            "--accept-routes"
          ];
          services.enable = true;
        };

        services.samba = {
          enable = true;
          users = [
            rec {
              name = "le0";
              password-file = config.age.secrets."${name}-password".path;
            }
          ];
          settings = {
            "public" = {
              "path" = "/tmp";
              "public" = "no";
              "browseable" = "yes";
              "read only" = "yes";
              "force user" = "root";
            };
          };
        };

        services.yggdrasil = {
          enable = false;
          persistentKeys = true;
          settings = {
            Peers = [
              "quic://145.239.92.251:51812?key=63190e3dfc084ca063169a607b1786b4829193ebc8623ac0abdfd6608cd8ee6a"
              "quic://0.ygg.l1qu1d.net:11102?key=0000000998b5ff8c0f1115ce9212f772d0427151f50fe858e6de1d22600f1680"
              "quic://vpn.itrus.su:7993"
              "quic://109.107.177.127:65535"
            ];
          };
        };

        services.garage = {
          enable = true;
          package = pkgs.garage_2;
          settings = {
            db_engine = "sqlite";
            replication_factor = 1;
            rpc_bind_addr = "[::]:3901";
            s3_api = {
              s3_region = "garage";
              api_bind_addr = "[::]:3900";
              root_domain = ".s3.garage";
            };
          };
        };

        systemd.services.garage = {
          serviceConfig = {
            LoadCredential = "garage-rpc-secret:${config.age.secrets.garage-rpc-secret.path}";
            Environment = [
              "GARAGE_RPC_SECRET_FILE=%d/garage-rpc-secret"
              "GARAGE_ALLOW_WORLD_READABLE_SECRETS=true"
            ];
          };
        };

        environment.shellAliases.garage = "GARAGE_RPC_SECRET_FILE=${config.age.secrets.garage-rpc-secret.path} garage";

        networking.firewall.allowedTCPPorts = [ 3900 ];
      };
  };
}
