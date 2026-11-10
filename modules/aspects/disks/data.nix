{ lib, ... }:
{
  den.aspects."data@nu" =
    { host, disk, ... }:
    {
      disko = {
        type = "disk";
        device = disk.device;
        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-m raid1"
            "-d raid1"
            host.disks.data-mirror.device
          ];
          subvolumes =
            lib.genAttrs'
              [
                "downloads"
                "movies"
                "shows"
                "anime"
                "youtube"
                "audiobooks"
                "audiobooks-testing"
                "books"
                "comics"
                "photos"
                "documents"
                "game-saves"
              ]
              (
                name:
                lib.nameValuePair "${name}/active" {
                  mountpoint = "/srv/${name}";
                  mountOptions = [
                    "noatime"
                    "compress=zstd"
                  ];
                }
              );
        };
      };
    };
}
