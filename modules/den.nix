{ inputs, den, lib, ... }:

{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.x86_64-linux.tau = { };
  den.hosts.x86_64-linux.nu = { };

  den.default.includes = [
    den.batteries.hostname
    den.batteries.define-user
  ];
}
