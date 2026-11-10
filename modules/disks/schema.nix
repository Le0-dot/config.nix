{
  den,
  lib,
  inputs,
  ...
}:
let
  inherit (import "${inputs.den}/nix/lib/entities/_types.nix" { inherit lib den; }) lookupAspectBy;
in
{
  den.schema.disk = {
    inherits = [ den.schema.conf ];
    parent = "host";
  };

  den.policies.host-to-disks =
    { host, ... }:
    map (disk: den.lib.policy.resolve.shared { inherit disk; }) (lib.attrValues host.disks);

  den.schema.host =
    { host, ... }:
    {
      options.disks = lib.mkOption {
        description = "Physical disks of this host.";
        default = { };
        type = lib.types.attrsOf (
          den.lib.schema.mkInstanceType {
            extraModules = [
              (
                { config, ... }:
                {
                  config._module.args.host = host;
                  options = {
                    diskName = lib.mkOption {
                      description = "Disk name in disko.devices.disk. Defaults to the attribute name, which also selects the aspect.";
                      type = lib.types.str;
                      default = config.name;
                    };
                    description = lib.mkOption {
                      description = "Disk description";
                      type = lib.types.str;
                      default = "disk.${config.diskName}@${host.name}";
                    };
                    device = lib.mkOption {
                      description = "Device path, preferably /dev/disk/by-id/...";
                      type = lib.types.str;
                      example = "/dev/disk/by-id/nvme-Vendor_Model_Serial";
                    };
                    aspect = lib.mkOption {
                      description = ''
                        Aspect that configures this disk. Both den.aspects.<name>@<host>
                        and den.aspects.<name> apply where they exist.
                      '';
                      type = lib.types.raw;
                      defaultText = "den.aspects.<name>@<host> and den.aspects.<name>";
                      default = lookupAspectBy den [
                        "${config.name}@${host.name}"
                        config.name
                      ];
                    };
                    host = lib.mkOption {
                      description = "The host this disk is attached to.";
                      default = host;
                      defaultText = lib.literalExpression "host";
                    };
                  };
                }
              )
            ];
          } den.schema.disk
        );
      };
      config.includes = [ den.policies.host-to-disks ];
    };
}
