{
  den,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.den.flakeModule ];

  systems = lib.systems.flakeExposed;

  den.schema.home = { name, ... }: {
    name = lib.mkOverride 30 name; # make user@host1 != user@host2
  };

  den.default = {
    nixos.system.stateVersion = lib.mkDefault "25.05";
    homeManager.home.stateVersion = lib.mkDefault "26.05";
    homeManager.imports = [ inputs.stylix.homeModules.stylix ];
    includes = [
      den.batteries.define-user
      (
        { home }:
        lib.optional (den.aspects ? ${home.userName}) (den.lib.policy.include den.aspects.${home.userName})
      )
    ];
  };

  den.hosts.x86_64-linux.nu = { };
  den.hosts.x86_64-linux.tau = { };
  den.hosts.x86_64-linux.omega.class = "systemManager";

  den.homes.x86_64-linux."lev.koliadich@nu" = { };
  den.homes.x86_64-linux."lev.koliadich@tau" = { };
  den.homes.x86_64-linux."lev.koliadich@omega" = { };
}
