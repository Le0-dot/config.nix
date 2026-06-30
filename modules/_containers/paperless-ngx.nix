{ config, flake, ... }:

let
  tailnet = "spitz-mora.ts.net";
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes;
    in
    {
      pods.paperless-ngx.podConfig = {
        publishPorts = [ "8010:8000" ];
        labels = {
          "tailscale.service.paperless-ngx.https" = "8010";
        };
      };
      volumes.paperless-ngx = btrfsVolume {
        disk = "main";
        partition = "root";
        subvol = "containers/paperless-ngx/active";
      };
      containers = {
        paperless-ngx-main.containerConfig = {
          image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.3";
          pod = pods.paperless-ngx.ref;
          mounts = [
            (mountVolume {
              volume = volumes.paperless-ngx.ref;
              subpath = "/data";
              destination = "/usr/src/paperless/data";
            })
            (mountVolume {
              volume = volumes.paperless-ngx.ref;
              subpath = "/media";
              destination = "/usr/src/paperless/media";
            })
          ];
          environments = {
            PAPERLESS_REDIS = "redis://localhost:6379";
            PAPERLESS_URL = "https://paperless-ngx.${tailnet}";
          };
        };
        paperless-ngx-redis.containerConfig = {
          image = "docker.io/redis:8.4.0";
          pod = pods.paperless-ngx.ref;
          mounts = [
            (mountVolume {
              volume = volumes.paperless-ngx.ref;
              subpath = "/redis";
              destination = "/data";
            })
          ];
        };
      };
    };
}
