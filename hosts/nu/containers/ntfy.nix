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
      networks.ntfy.networkConfig = { };
      pods.ntfy.podConfig = {
        publishPorts = [ "8090:80" ];
        networks = [
          "podman"
          networks.ntfy.ref
        ];
        labels = {
          "tailscale.service.ntfy.https" = "8090";
        };
      };
      volumes.ntfy = btrfsVolume {
        disk = "main";
        partition = "root";
        subvol = "containers/ntfy/active";
      };
      containers.ntfy-main.containerConfig = {
        image = "docker.io/binwiederhier/ntfy:latest";
        exec = [ "serve" ];
        pod = pods.ntfy.ref;
        mounts = [
          (mountVolume {
            volume = volumes.ntfy.ref;
            subpath = "/config";
            destination = "/etc/ntfy";
          })
          (mountVolume {
            volume = volumes.ntfy.ref;
            subpath = "/cache";
            destination = "/var/cache/ntfy";
          })
        ];
      };
    };
}
