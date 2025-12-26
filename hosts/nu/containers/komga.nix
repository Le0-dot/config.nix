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
      pods.komga.podConfig = {
        publishPorts = [
          "25600:25600"
        ];
        labels = {
          "tailscale.service.komga.https" = "25600";
        };
      };
      volumes = {
        komga = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/komga/active";
        };
        comics = btrfsVolume {
          disk = "data";
          subvol = "comics";
        };
      };
      containers.komga-main.containerConfig = {
        image = "docker.io/gotson/komga:1.23.6";
        pod = pods.komga.ref;
        mounts = [
          (mountVolume {
            volume = volumes.komga.ref;
            subpath = "/config";
            destination = "/config";
          })
          (mountVolume {
            volume = volumes.comics.ref;
            destination = "/data";
          })
        ];
      };
    };
}
