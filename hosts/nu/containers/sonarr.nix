{ config, flake, ... }:

let
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes networks;
    in
    {
      pods.sonarr.podConfig = {
        publishPorts = [
          "8989:8989"
        ];
        networks = [
          "podman"
          networks.torrents.ref
        ];
        labels = {
          "tailscale.service.sonarr.https" = "8989";
        };
      };
      volumes = {
        sonarr = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/sonarr/active";
        };
      };
      containers.sonarr-main.containerConfig = {
        image = "lscr.io/linuxserver/sonarr:4.0.16";
        pod = pods.sonarr.ref;
        mounts = [
          (mountVolume {
            volume = volumes.sonarr.ref;
            subpath = "/config";
            destination = "/config";
          })
          (mountVolume {
            volume = volumes.downloads.ref;
            destination = "/downloads";
          })
          (mountVolume {
            volume = volumes.shows.ref;
            destination = "/data/shows";
          })
          (mountVolume {
            volume = volumes.anime.ref;
            destination = "/data/anime";
          })
        ];
        environments = {
          PUID = "0";
          PGID = "0";
        };
      };
    };
}
