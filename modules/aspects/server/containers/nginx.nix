{
  den.aspects.tau.nginx = {
    nixos =
      { config, ... }:
      {
        virtualisation.quadlet =
          let
            inherit (config.virtualisation.quadlet) pods;
          in
          {
            pods.nginx.podConfig = {
              publishPorts = [ "8080:80" ];
              labels = {
                "tailscale.service.nginx.https" = "8080";
              };
            };
            containers.nginx-main.containerConfig = {
              image = "docker.io/library/nginx:latest";
              pod = pods.nginx.ref;
            };
          };
      };
  };
}
