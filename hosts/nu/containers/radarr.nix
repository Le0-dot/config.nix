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
      pods.radarr.podConfig = {
        publishPorts = [
          "7878:7878"
        ];
        networks = [
          "podman"
          networks.torrents.ref
        ];
        labels = {
          "tailscale.service.radarr.https" = "7878";
        };
      };
      volumes = {
        radarr = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/radarr/active";
        };
      };
      containers.radarr-main.containerConfig = {
        image = "lscr.io/linuxserver/radarr:6.0.4";
        pod = pods.radarr.ref;
        mounts = [
          (mountVolume {
            volume = volumes.radarr.ref;
            subpath = "/config";
            destination = "/config";
          })
          (mountVolume {
            volume = volumes.downloads.ref;
            destination = "/downloads";
          })
          (mountVolume {
            volume = volumes.movies.ref;
            destination = "/data";
          })
        ];
        environments = {
          PUID = "0";
          PGID = "0";
        };
      };
    };
}
