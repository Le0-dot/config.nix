{
  den,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  systems = lib.systems.flakeExposed;

  den.default = {
    includes = [
      den.batteries.define-user
      den.policies.include-username-aspect
      den.aspects.nix
      den.aspects.stylix
    ];
    nixos = {
      system.stateVersion = lib.mkDefault "25.05";
      imports = [
        inputs.disko.nixosModules.disko
        inputs.agenix.nixosModules.default
      ];
    };
    homeManager = {
      home.stateVersion = lib.mkDefault "26.05";
      imports = [ inputs.agenix.homeManagerModules.default ];
    };
  };

  den.hosts.x86_64-linux.nu.users."lev.koliadich" = { };
  den.hosts.x86_64-linux.tau.users."lev.koliadich" = { };
  den.hosts.x86_64-linux.omega.class = "systemManager";

  den.homes.x86_64-linux."lev.koliadich@nu" = { };
  den.homes.x86_64-linux."lev.koliadich@tau" = { };
  den.homes.x86_64-linux."lev.koliadich@omega" = { };
}
