let
  root_disk = "/dev/disk/by-id/nvme-Lexar_SSD_NM620_512GB_QFB155R004190P110W";
  data_disk1 = "/dev/disk/by-id/nvme-ADATA_LEGEND_900_4N4221121212";
  data_disk2 = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2516E9B84F3A";
in
{
  disko.devices.disk = {
    main = {
      type = "disk";
      device = root_disk;
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF02";
            size = "1M";
          };
          ESP = {
            type = "EF00";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/" = {
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                    "ssd"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "ssd"
                  ];
                };
              };
            };
          };
        };
      };
    };
    data = {
      type = "disk";
      device = data_disk1;
      content = {
        type = "btrfs";
        extraArgs = [
          "-f"
          "-m raid1"
          "-d raid1"
          data_disk2
        ];
        subvolumes = {
          "/data" = {
            mountpoint = "/srv/data";
            mountOptions = [
              "compress=zstd"
              "noatime"
              "ssd"
            ];
          };
        };
      };
    };
  };
}
