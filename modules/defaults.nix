{
  den,
  lib,
  self,
  inputs,
  ...
}:
{
  den.default = {
    includes = [
      den.aspects.nix
      den.aspects.stylix
      den.aspects.nix-system-graphics
    ];
    nixos = {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.quadlet-nix.nixosModules.quadlet
      ];
      system.stateVersion = lib.mkDefault "25.05";
      system.configurationRevision = self.rev or null;
    };
    homeManager = {
      imports = [ inputs.agenix.homeManagerModules.default ];
      home.stateVersion = lib.mkDefault "26.05";
    };
  };
}
