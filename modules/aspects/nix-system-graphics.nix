{ inputs, ... }:
{
  den.aspects.nix-system-graphics = {
    systemManager = {
      imports = [ inputs.nix-system-graphics.systemModules.default ];
      system-graphics.enable = true;
    };
  };
}
