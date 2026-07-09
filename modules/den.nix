{
  inputs,
  den,
  lib,
  ...
}:

{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.schema.home = { name, config, ... }: {
    name = lib.mkOverride 30 name; # make user@host1 != user@host2
    aspect = den.aspects.${config.userName};
  };

  den.default = {
    nixos.system.stateVersion = lib.mkDefault "25.05";
    homeManager.home.stateVersion = lib.mkDefault "26.05";
    includes = [
      den.batteries.define-user
      (
        { home }:
        lib.optional (den.aspects ? ${home.name}) (den.lib.policy.include den.aspects.${home.name})
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
