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
      den.aspects.nix-system-graphics
    ];
    nixos = {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.agenix.nixosModules.default
        inputs.quadlet-nix.nixosModules.quadlet
      ];
      system.stateVersion = lib.mkDefault "25.05";
    };
    homeManager = {
      imports = [ inputs.agenix.homeManagerModules.default ];
      home.stateVersion = lib.mkDefault "26.05";
    };
  };
}
