{
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

    flake.nixosModules.samba
    flake.nixosModules.tailscale

    ./hardware-configuration.nix
    ./disk-config.nix
    ./secrets.nix
  ];

  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nix.gc.automatic = true;

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
      users.le0.isNormalUser = true;
    };

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
      enable = true;
      persistentKeys = true;
      settings = {
        Peers = [
          # Poland
          "quic://145.239.92.251:51812?key=63190e3dfc084ca063169a607b1786b4829193ebc8623ac0abdfd6608cd8ee6a"
          "quic://0.ygg.l1qu1d.net:11102?key=0000000998b5ff8c0f1115ce9212f772d0427151f50fe858e6de1d22600f1680"
          # Netherlands
          "quic://vpn.itrus.su:7993"
          "quic://109.107.177.127:65535"
        ];
        # PrivateKeyPath = ...; # TODO
      };
    };
  };
}
