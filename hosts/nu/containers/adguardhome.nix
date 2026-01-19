{
  pkgs,
  flake,
  config,
  ...
}:

let
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
  envFile = "/run/containers/environment/tailscale-ip";
in
{
  systemd.services.tailscale-env = {
    description = "Export Tailscale IP to environment file";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    path = [ pkgs.tailscale ];
    preStart = "until tailscale status; do sleep 10; done";
    script = ''
      mkdir -p $(dirname ${envFile})
      echo "TAILSCALE_IP=$(tailscale ip -4)" > ${envFile}
    '';
  };

  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes;
    in
    {
      pods.adguardhome = {
        unitConfig = {
          After = [ "tailscale-env.service" ];
          Requires = [ "tailscale-env.service" ];
        };
        serviceConfig = {
          EnvironmentFile = envFile;
        };
        podConfig = {
          publishPorts = [
            "3000:3000"
            "\${TAILSCALE_IP}:53:53/udp"
            "\${TAILSCALE_IP}:53:53/tcp"
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
