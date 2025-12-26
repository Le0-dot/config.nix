{ config, flake, ... }:

let
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes;
    in
    {
      pods.media.podConfig = {
        publishPorts = [ "8096:8096" ];
        labels = {
          "tailscale.service.jellyfin.https" = "8096";
        };
      };
      volumes = {
        jellyfin = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/jellyfin/active";
        };
        movies = btrfsVolume {
          disk = "data";
          subvol = "movies";
        };
        shows = btrfsVolume {
          disk = "data";
          subvol = "shows";
        };
        anime = btrfsVolume {
          disk = "data";
          subvol = "anime";
        };
      };
      containers.jellyfin-main.containerConfig = {
        image = "docker.io/jellyfin/jellyfin:10.11.5";
        pod = pods.media.ref;
        mounts = [
          (mountVolume {
            volume = volumes.jellyfin.ref;
            subpath = "/config";
            destination = "/config";
          })
          (mountVolume {
            volume = volumes.jellyfin.ref;
            subpath = "/cache";
            destination = "/cache";
          })
          (mountVolume {
            volume = volumes.movies.ref;
            destination = "/media/movies";
          })
          (mountVolume {
            volume = volumes.shows.ref;
            destination = "/media/shows";
          })
          (mountVolume {
            volume = volumes.anime.ref;
            destination = "/media/anime";
          })
          # TODO: use youtarr or similar to download youtube content
          # (mountVolume {
          #   volume = volumes.youtube.ref;
          #   destination = "/media/youtube";
          # })
        ];
        devices = [ "/dev/dri" ];
      };
    };
}
