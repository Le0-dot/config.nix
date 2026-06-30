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
      pods.homeassistant.podConfig = {
        publishPorts = [
          "8123:8123"
        ];
        labels = {
          "tailscale.service.homeassistant.https" = "8123";
        };
      };
      volumes = {
        homeassistant = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/homeassistant/active";
        };
      };
      containers.homeassistant-main.containerConfig = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        pod = pods.homeassistant.ref;
        mounts = [
          (mountVolume {
            volume = volumes.homeassistant.ref;
            subpath = "/config";
            destination = "/config";
          })
        ];
      };
    };
}
