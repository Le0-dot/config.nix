{ config, ... }:

let
  tailnet = "spitz-mora.ts.net";
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes;
    in
    {
      pods.paperless-ngx-pod.podConfig = {
        publishPorts = [ "8010:8000" ];
      };
      volumes.paperless-ngx.volumeConfig = {
        type = "btrfs";
        device = "/dev/disk/by-id/nvme-Lexar_SSD_NM620_512GB_QFB155R004190P110W-part2";
        options = "subvol=containers/paperless-ngx/active";
      };
      containers = {
        paperless-ngx.containerConfig = {
          image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.3";
          pod = pods.paperless-ngx-pod.ref;
          mounts = [
            "type=volume,source=${volumes.paperless-ngx.ref},destination=/usr/src/paperless/data,subpath=/data"
            "type=volume,source=${volumes.paperless-ngx.ref},destination=/usr/src/paperless/media,subpath=/media"
          ];
          environments = {
            PAPERLESS_REDIS = "redis://localhost:6379";
            PAPERLESS_URL = "https://paperless-ngx.${tailnet}";
          };
        };
        paperless-ngx-redis.containerConfig = {
          image = "docker.io/redis:8.4.0";
          pod = pods.paperless-ngx-pod.ref;
          mounts = [
            "type=volume,source=${volumes.paperless-ngx.ref},destination=/data,subpath=/redis"
          ];
        };
      };
    };
}
