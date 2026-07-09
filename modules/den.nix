{ inputs, lib, ... }:

{
  imports = [ inputs.den.flakeModule ];

  systems = lib.systems.flakeExposed;

  den.default = {
    nixos.system.stateVersion = lib.mkDefault "25.05";
    homeManager.home.stateVersion = lib.mkDefault "26.05";
  };

  den.hosts.x86_64-linux.nu = { };
  den.hosts.x86_64-linux.tau = { };
  den.hosts.x86_64-linux.omega.class = "systemManager";

  den.homes.x86_64-linux."lev.koliadich@nu" = { };
  den.homes.x86_64-linux."lev.koliadich@tau" = { };
  den.homes.x86_64-linux."lev.koliadich@omega" = { };
}
