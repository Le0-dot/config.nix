{ inputs, den, lib, ... }:

{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.includes = [
    den.batteries.hostname
    den.batteries.define-user
  ];

  den.default.nixos.system.stateVersion = "25.05";
  den.default.homeManager.home.stateVersion = "26.05";
}
