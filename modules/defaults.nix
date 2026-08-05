{
  den,
  lib,
  inputs,
  ...
}:
{
  den.default = {
    includes = [
      # den.batteries.hostname
      den.aspects.nix
      den.aspects.stylix
    ];
    nixos = {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.agenix.nixosModules.default
        inputs.quadlet-nix.nixosModules.quadlet
      ];
      system.stateVersion = lib.mkDefault "25.05";
    };
    systemManager = {
      imports = [ inputs.nix-system-graphics.systemModules.default ];
      system-graphics.enable = true;
    };
    homeManager = {
      imports = [ inputs.agenix.homeManagerModules.default ];
      home.stateVersion = lib.mkDefault "26.05";
    };
  };
}
