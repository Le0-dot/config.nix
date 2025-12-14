{ lib, config, ... }:

let
  blockDeviceToOption =
    {
      destination,
      disk,
      partition,
      opts,
      path,
    }:
    let
      volumeOpts = builtins.concatStringsSep "," (
        lib.attrsets.mapAttrsToList (key: value: "volume-opt=${key}=${value}") (
          {
            type =
              if partition == null then
                config.disko.devices.disk.${disk}.content.type
              else
                config.disko.devices.disk.${disk}.content.partitions.${partition}.content.type;
            device =
              if partition == null then
                config.disko.devices.disk.${disk}.device
              else
                config.disko.devices.disk.${disk}.content.partitions.${partition}.device;
          }
          // lib.attrsets.mapAttrs' (key: value: lib.attrsets.nameValuePair "o=${key}" value) opts
        )
      );
    in
    [
      "--mount"
      "type=volume,dst=${destination},${volumeOpts},volume-subpath=${path}"
    ];
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
                      type = lib.types.nullOr lib.types.str;
                      description = "The partition on the block device to mount.";
                      default = null;
                    };
                    opts = lib.mkOption {
                      type = lib.types.attrsOf lib.types.str;
                      description = "Mount options for the block device.";
                      default = { };
                    };
                    path = lib.mkOption {
                      type = lib.types.str;
                      description = "The path on the filesystem of the block device to mount.";
                      default = "/";
                    };
                  };
                }
              );
              description = "List of block devices to mount inside the container.";
              default = [ ];
            };
          };

          config = {
            extraOptions = builtins.concatMap blockDeviceToOption config.blockDevices;
          };
        }
      )
    );
  };
}
