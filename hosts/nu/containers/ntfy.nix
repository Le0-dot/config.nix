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
        environments = {
          "NTFY_BASE_URL" = "https://ntfy.spitz-more.ts.net";
          "NTFY_CACHE_FILE" = "/var/lib/ntfy/cache.db";
          "NTFY_AUTH_FILE" = "/var/lib/ntfy/auth.db";
          "NTFY_ATTACHMENT_CACHE_DIR" = "/var/lib/ntfy/attachments";
          "NTFY_AUTH_DEFAULT_ACCESS" = "write-only";
          "NTFY_AUTH_USERS" = "le0:$$2a$$10$$64Ml8HSQjNNG80IIAmZSVenz75miMpGvx65V9ENETcbBS6vIDa8iu:admin";
          "NTFY_ENABLE_LOGIN" = "true";
        };
        mounts = [
          (mountVolume {
            volume = volumes.ntfy.ref;
            subpath = "/data";
            destination = "/var/lib/ntfy";
          })
        ];
      };
    };
}
