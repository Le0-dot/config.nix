{
  den.aspects.main =
    { disk, ... }:
    {
      disko = {
        type = "disk";
        device = disk.device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes.root = {
                  mountpoint = "/";
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };

  den.aspects."main@nu" = {
    disko.content.partitions.root.content.subvolumes.nix = {
      mountpoint = "/nix/store";
      mountOptions = [
        "noatime"
        "compress=zstd"
      ];
    };
  };
}
