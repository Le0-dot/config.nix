{ config, flake, ... }:

let
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
  mountBind = flake.lib.mountBind;
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes networks;
    in
    {
      networks.jellyfin.networkConfig = { };
      pods.jellyfin.podConfig = {
        publishPorts = [ "8096:8096" ];
        labels = {
          "tailscale.service.jellyfin.https" = "8096";
        };
        networks = [
          "podman"
          networks.jellyfin.ref
        ];
      };
      volumes = {
        jellyfin = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/jellyfin/active";
        };
        movies = btrfsVolume {
          disk = "data";
          subvol = "movies/active";
        };
        shows = btrfsVolume {
          disk = "data";
          subvol = "shows/active";
        };
        anime = btrfsVolume {
          disk = "data";
          subvol = "anime/active";
        };
      };
      containers.jellyfin-main.containerConfig = {
        image = "docker.io/jellyfin/jellyfin:10.11.5";
        pod = pods.jellyfin.ref;
        mounts = [
          # (mountVolume {
          #   volume = volumes.jellyfin.ref;
          #   subpath = "/config";
          #   destination = "/config";
          # })
          # (mountVolume {
          #   volume = volumes.jellyfin.ref;
          #   subpath = "/cache";
          #   destination = "/cache";
          # })
          # (mountVolume {
          #   volume = volumes.movies.ref;
          #   destination = "/media/movies";
          # })
          # (mountVolume {
          #   volume = volumes.shows.ref;
          #   destination = "/media/shows";
          # })
          # (mountVolume {
          #   volume = volumes.anime.ref;
          #   destination = "/media/anime";
          # })
          (mountBind {
            source = "/srv/containers/jellyfin/config";
            destination = "/config";
          })
          (mountBind {
            source = "/srv/containers/jellyfin/cache";
            destination = "/cache";
          })
          (mountBind {
            source = "srv/movies";
            destination = "/media/movies";
          })
          (mountBind {
            source = "srv/shows";
            destination = "/media/shows";
          })
          (mountBind {
            source = "srv/anime";
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
