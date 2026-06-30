# omega is a non-NixOS workstation managed by system-manager.
# Uses `instantiate` override to call makeSystemConfig instead of nixosSystem.
{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.omega = {
    instantiate = { modules, ... }:
      inputs.system-manager.lib.makeSystemConfig {
        inherit modules;
        specialArgs = { inherit inputs; };
      };
    intoAttr = [ "systemConfigurations" "omega" ];
  };

  den.aspects.omega = {
    excludes = [
      den.batteries.hostname # system-manager has no networking.hostName
    ];
    nixos = { pkgs, ... }: {
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
