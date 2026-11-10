{ self, ... }:
{
  den.aspects."data-mirror@nu" =
    { host, disk, ... }:
    {
      checks =
        { lib, pkgs, ... }:
        let
          defined = lib.filterAttrs (
            name: d: name == disk.diskName || d.device == disk.device
          ) self.nixosConfigurations.${host.name}.config.disko.devices.disk;
        in
        {
          "assert-${host.name}-${disk.diskName}-not-in-disko" =
            lib.throwIf (defined != { })
              "${host.name}: disk ${disk.diskName} (${disk.device}) must not be defined in disko, found: ${toString (lib.attrNames defined)}"
              (pkgs.runCommand "assert-${host.name}-${disk.diskName}-not-in-disko" { } "touch $out");
        };
    };
}
