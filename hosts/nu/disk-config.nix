let
  root-disk = "/dev/disk/by-id/nvme-Lexar_SSD_NM620_512GB_QFB155R004190P110W";
  data-disk-1 = "/dev/disk/by-id/nvme-ADATA_LEGEND_900_4N4221121212";
  data-disk-2 = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2516E9B84F3A";

  data-mount-options = [
    "noatime"
    "compress=zstd"
  ];
in
{
  disko.devices.disk = {
    main = {
      type = "disk";
      device = root-disk;
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
              subvolumes = {
                root = {
                  mountpoint = "/";
                  mountOptions = [ "noatime" ];
                };
                nix = {
                  mountpoint = "/nix/store";
                  mountOptions = [
                    "noatime"
                    "compress=zstd"
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
      device = data-disk-1;
      content = {
        type = "btrfs";
        extraArgs = [
          "-f"
          "-m raid1"
          "-d raid1"
          data-disk-2
        ];
        subvolumes = {
          "downloads/active" = {
            mountpoint = "/srv/downloads";
            mountOptions = data-mount-options;
          };
          "movies/active" = {
            mountpoint = "/srv/movies";
            mountOptions = data-mount-options;
          };
          "shows/active" = {
            mountpoint = "/srv/shows";
            mountOptions = data-mount-options;
          };
          "anime/active" = {
            mountpoint = "/srv/anime";
            mountOptions = data-mount-options;
          };
          "youtube/active" = {
            mountpoint = "/srv/youtube";
            mountOptions = data-mount-options;
          };
          "audiobooks/active" = {
            mountpoint = "/srv/audiobooks";
            mountOptions = data-mount-options;
          };
          "books/active" = {
            mountpoint = "/srv/books";
            mountOptions = data-mount-options;
          };
          "comics/active" = {
            mountpoint = "/srv/comics";
            mountOptions = data-mount-options;
          };
          "photos/active" = {
            mountpoint = "/srv/photos";
            mountOptions = data-mount-options;
          };
          "documents/active" = {
            mountpoint = "/srv/documents";
            mountOptions = data-mount-options;
          };
          "game-saves/active" = {
            mountpoint = "/srv/game-saves";
            mountOptions = data-mount-options;
          };
        };
      };
    };
  };
}
