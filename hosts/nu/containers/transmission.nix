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
      networks.torrents.networkConfig = { };
      pods.transmission.podConfig = {
        publishPorts = [
          "9091:9091"
          "51413:51413/tcp"
          "51413:51413/udp"
        ];
        networks = [
          "podman"
          networks.torrents.ref
        ];
        labels = {
          "tailscale.service.transmission.https" = "9091";
        };
      };
      volumes = {
        transmission = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/transmission/active";
        };
        downloads = btrfsVolume {
          disk = "data";
          subvol = "downloads";
        };
      };
      containers.transmission-main.containerConfig = {
        image = "lscr.io/linuxserver/transmission:4.0.6";
        pod = pods.transmission.ref;
        mounts = [
          (mountVolume {
            volume = volumes.transmission.ref;
            subpath = "/config";
            destination = "/config";
          })
          (mountVolume {
            volume = volumes.downloads.ref;
            destination = "/downloads";
          })
        ];
        environments = {
          PUID = "0";
          PGID = "0";
        };
      };
    };
}
