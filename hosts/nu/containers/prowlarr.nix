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
      pods.prowlarr.podConfig = {
        publishPorts = [
          "9696:9696"
        ];
        networks = [
          "podman"
          networks.torrents.ref
        ];
        labels = {
          "tailscale.service.prowlarr.https" = "9696";
        };
      };
      volumes = {
        prowlarr = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/prowlarr/active";
        };
      };
      containers.prowlarr-main.containerConfig = {
        image = "lscr.io/linuxserver/prowlarr:2.3.0";
        pod = pods.prowlarr.ref;
        mounts = [
          (mountVolume {
            volume = volumes.prowlarr.ref;
            subpath = "/config";
            destination = "/config";
          })
        ];
        environments = {
          PUID = "0";
          PGID = "0";
        };
      };
    };
}
