{ ... }:

{
  btrfsVolume =
    disko-config:
    {
      disk,
      partition ? null,
      subvol,
    }:
    let
      devicePath =
        if partition == null then
          disko-config.devices.disk.${disk}.device
        else
          disko-config.devices.disk.${disk}.content.partitions.${partition}.device;
    in
    {
      volumeConfig = {
        type = "btrfs";
        device = devicePath;
        options = "subvol=${subvol}";
      };
    };
  mountVolume =
    {
      volume,
      subpath,
      destination,
    }:
    "type=volume,source=${volume},subpath=${subpath},destination=${destination}";
}
