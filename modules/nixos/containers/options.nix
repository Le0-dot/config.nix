{
  lib,
  flake,
  config,
  ...
}:

let
  blockDeviceToOption =
    {
      destination,
      disk,
      partition,
      opts,
    }:
    let
      escapeValue = str: if lib.strings.hasInfix "," str then lib.strings.escapeNixString str else str; # FIXME
      volumeOpts = builtins.concatStringsSep "," (
        lib.attrsets.mapAttrsToList (key: value: "volume-opt=${key}=${escapeValue value}") (
          {
            type = flake.lib.getFs config disk partition;
            device = flake.lib.getDevice config disk partition;
          }
          // opts
        )
      );
    in
    ''
      --mount="type=volume,dst=${destination},volume-driver=local,${volumeOpts}"
    '';
in
{
  options.virtualisation.oci-containers.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          options = {
            blockDevices = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    destination = lib.mkOption {
                      type = lib.types.str;
                      description = "The mount point inside the container.";
                    };
                    disk = lib.mkOption {
                      type = lib.types.str;
                      description = "The block device to mount.";
                    };
                    partition = lib.mkOption {
                      type = lib.types.str;
                      description = "The partition on the block device to mount.";
                    };
                    opts = lib.mkOption {
                      type = lib.types.attrsOf lib.types.str;
                      description = "Mount options for the block device.";
                      default = { };
                    };
                  };
                }
              );
              description = "List of block devices to mount inside the container.";
              default = [ ];
            };
          };

          config = {
            extraOptions = map blockDeviceToOption config.blockDevices;
          };
        }
      )
    );
  };
}
