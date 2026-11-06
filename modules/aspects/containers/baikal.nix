{ self, ... }:
{
  den.aspects.baikal.quadlet =
    {
      osConfig,
      pods,
      volumes,
      ...
    }:
    let
      btrfsVolume = self.lib.btrfsVolume osConfig.disko;
      mountVolume = self.lib.mountVolume;
    in
    {
      pods.baikal.podConfig = {
        publishPorts = [ "9080:80" ];
        labels = {
          "tailscale.service.baikal.https" = "9080";
        };
      };
      volumes.baikal = btrfsVolume {
        disk = "main";
        partition = "root";
        subvol = "containers/baikal/active";
      };
      containers.baikal-main.containerConfig = {
        image = "docker.io/ckulka/baikal:0.10.1-nginx";
        pod = pods.baikal.ref;
        mounts = [
          (mountVolume {
            volume = volumes.baikal.ref;
            subpath = "/config";
            destination = "/var/www/baikal/config";
          })
          (mountVolume {
            volume = volumes.baikal.ref;
            subpath = "/data";
            destination = "/var/www/baikal/Specific";
          })
        ];
      };
    };
}
