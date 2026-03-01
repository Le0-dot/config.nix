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
      pods.jellyseerr.podConfig = {
        publishPorts = [ "5055:5055" ];
        networks = [
          "podman"
          networks.jellyfin.ref
          networks.torrents.ref
        ];
        labels = {
          "tailscale.service.jellyseerr.https" = "5055";
        };
      };
      volumes = {
        jellyseerr = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/jellyseerr/active";
        };
      };
      containers.jellyseerr-main.containerConfig = {
        image = "ghcr.io/fallenbagel/jellyseerr:2.7.3";
        pod = pods.jellyseerr.ref;
        mounts = [
          (mountVolume {
            volume = volumes.jellyseerr.ref;
            subpath = "/config";
            destination = "/app/config";
          })
        ];
      };
    };
}
