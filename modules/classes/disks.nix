{
  den,
  lib,
  inputs,
  ...
}:
let
  forward =
    { host, aspect-chain }:
    den.batteries.forward {
      each = lib.singleton host;
      fromClass = _: "disk";
      intoClass = _: "nixos";
      intoPath = _: [
        "disko"
        "devices"
        "disk"
      ];
      fromAspect = _: lib.head aspect-chain;
    };
in
{
  den.schema.host.includes = [ forward ];
  den.default.nixos.imports = [ inputs.disko.nixosModules.disko ];
}
