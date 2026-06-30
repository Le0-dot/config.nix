# omega is a non-NixOS workstation managed by system-manager.
# Den has built-in support for class = "systemManager":
#   instantiate defaults to inputs.system-manager.lib.makeSystemConfig
#   intoAttr defaults to [ "systemConfigs" name ]
{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.omega = {
    class = "systemManager";
    # Override intoAttr to match our existing output path
    intoAttr = [ "systemConfigurations" "omega" ];
  };

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
