{
  den.aspects."backup@nu" =
    { disk, ... }:
    {
      disko = {
        type = "disk";
        device = disk.device;
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
        };
      };
    };
}
