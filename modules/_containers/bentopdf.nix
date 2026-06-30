{ config, ... }:

{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods;
    in
    {
      pods.bentopdf.podConfig = {
        publishPorts = [ "8181:8080" ];
        labels = {
          "tailscale.service.bentopdf.https" = "8181";
        };
      };
      containers.bentopdf-main.containerConfig = {
        image = "docker.io/bentopdf/bentopdf-simple:latest";
        pod = pods.bentopdf.ref;
      };
    };
}
