{ inputs, den, ... }:
{
  den.aspects.omega = {
    excludes = [
      den.batteries.hostname # system-manager has no networking.hostName
    ];
    systemManager = { pkgs, ... }: {
      imports = [
        inputs.nix-system-graphics.systemModules.default
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
      system-graphics.enable = true;
    };
  };
}
