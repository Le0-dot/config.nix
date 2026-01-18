{ flake, config, ... }:

let
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
  tailcaleIp = "100.83.204.23";
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes;
    in
    {
      pods.adguardhome = {
        podConfig = {
          publishPorts = [
            "3000:3000"
            "${tailcaleIp}:53:53/udp"
            "${tailcaleIp}:53:53/tcp"
          ];
          labels = {
            "tailscale.service.adguardhome.https" = "3000";
          };
        };
      };
      volumes.adguardhome = btrfsVolume {
        disk = "main";
        partition = "root";
        subvol = "containers/adguardhome/active";
      };
      containers.adguardhome-main.containerConfig = {
        image = "docker.io/adguard/adguardhome:v0.107.71";
        pod = pods.adguardhome.ref;
        mounts = [
          (mountVolume {
            volume = volumes.adguardhome.ref;
            subpath = "/config";
            destination = "/opt/adguardhome/conf";
          })
          (mountVolume {
            volume = volumes.adguardhome.ref;
            subpath = "/data";
            destination = "/opt/adguardhome/work";
          })
        ];
      };
    };
}
