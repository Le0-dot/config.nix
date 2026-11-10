{
  den,
  lib,
  inputs,
  ...
}:
{
  den.classes.disko.description = "Disk definition forwarded to the host's disko.devices.disk.<name>";

  den.policies.disko-to-host =
    { disk, host, ... }:
    lib.optional (host.class == "nixos") (
      den.lib.policy.route {
        fromClass = "disko";
        intoClass = host.class;
        path = [
          "disko"
          "devices"
          "disk"
          disk.diskName
        ];
      }
    );

  den.schema.disk.includes = [ den.policies.disko-to-host ];

  den.default.nixos.imports = [ inputs.disko.nixosModules.disko ];
}
