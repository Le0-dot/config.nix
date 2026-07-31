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
      den.batteries.hostname
      den.batteries.define-user
      den.policies.include-username-aspect
      den.policies.home-to-host
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

  den.hosts.x86_64-linux.nu = { };
  den.hosts.x86_64-linux.tau = { };
  den.hosts.x86_64-linux.omega.class = "systemManager";

  # den.homes.x86_64-linux."lev.koliadich@nu" = { };
  # den.homes.x86_64-linux."lev.koliadich@tau" = { };
  den.homes.x86_64-linux."lev.koliadich@omega" = { };
}
