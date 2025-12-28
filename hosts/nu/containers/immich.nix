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
      pods.immich.podConfig = {
        publishPorts = [
          "2283:2283"
        ];
        labels = {
          "tailscale.service.immich.https" = "2283";
        };
      };
      volumes = {
        immich = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/immich/active";
        };
        photos = btrfsVolume {
          disk = "data";
          subvol = "photos";
        };
      };
      containers = {
        immich-main.containerConfig = {
          image = "ghcr.io/immich-app/immich-server:release";
          pod = pods.immich.ref;
          mounts = [
            (mountVolume {
              volume = volumes.photos.ref;
              destination = "/data";
            })
          ];
          environments = {
            DB_HOSTNAME = "localhost";
            REDIS_HOSTNAME = "localhost";
            IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
          };
          devices = [ "/dev/dri" ];
        };
        immich-machine-learning.containerConfig = {
          image = "ghcr.io/immich-app/immich-machine-learning:release";
          pod = pods.immich.ref;
          mounts = [
            (mountVolume {
              volume = volumes.immich.ref;
              subpath = "/model-cache";
              destination = "/cache";
            })
          ];
        };
        immich-redis.containerConfig = {
          image = "docker.io/valkey/valkey:9@sha256:fb8d272e529ea567b9bf1302245796f21a2672b8368ca3fcb938ac334e613c8f";
          pod = pods.immich.ref;
        };
        immich-database.containerConfig = {
          image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
          pod = pods.immich.ref;
          mounts = [
            (mountVolume {
              volume = volumes.immich.ref;
              subpath = "/db";
              destination = "/var/lib/postgresql/data";
            })
          ];
          environments = {
            POSTGRES_DB = "immich";
            POSTGRES_USER = "postgres";
            POSTGRES_PASSWORD = "postgres";
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };
          shmSize = "128mb";
        };
      };
    };
}
