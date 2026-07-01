{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.omega.class = "systemManager";

  den.aspects.omega = {
    excludes = [
      den.batteries.hostname # system-manager has no networking.hostName
    ];
    systemManager = { pkgs, ... }: {
      imports = [
        inputs.nix-system-graphics.systemModules.default
        ../_system/uwsm.nix
        ../_system/hyprlock.nix
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
      system-graphics.enable = true;

      programs.uwsm.enable = true;
    };
  };
}
