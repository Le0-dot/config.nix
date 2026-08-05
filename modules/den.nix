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
      # den.batteries.hostname
      den.batteries.define-user
      den.policies.system-manager-users-defaults
      den.policies.host-specific-user-aspect
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
  den.hosts.x86_64-linux.omega = {
    class = "systemManager";
    users."lev.koliadich" = { };
  };
}
