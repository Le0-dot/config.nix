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
      ];
      system.stateVersion = lib.mkDefault "25.05";
      system.configurationRevision = self.rev or self.dirtyRev or null;
    };
    homeManager = {
      imports = [ inputs.agenix.homeManagerModules.default ];
      home.stateVersion = lib.mkDefault "26.05";
    };
  };
}
