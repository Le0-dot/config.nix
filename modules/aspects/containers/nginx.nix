{
  den.aspects.nginx = {
    oci-contaier = {
      nginx = {
        image = "docker.io/library/nginx:latest";
        ports = [ "8080:80" ];
        labels = {
          "tailscale.service.nginx.https" = "8080";
        };
      };
    };
    quadlet =
      { pods, ... }:
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
}
