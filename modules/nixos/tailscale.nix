{
  lib,
  pkgs,
  config,
  ...
}:

let
  notEmptyPorts = _container: { ports, ... }: ports != [ ];
  getHostPort = ports: builtins.head (builtins.split ":" (builtins.head ports)); # Assume format is "hostPort:containerPort" and publish only first port
  containerToService =
    container:
    { ports, ... }:
    lib.attrsets.nameValuePair "svc:${container}" {
      endpoints."tcp:443" = "https://127.0.0.1:${getHostPort ports}";
    };
  containerToServe =
    container:
    { ports, ... }:
    "${lib.getExe pkgs.tailscale} serve --service=svc:${container} --https=443 ${getHostPort ports}";
in
{
  options.services.tailscale.services = {
    enable = lib.mkEnableOption "Tailscale Services";
    enableContainers = lib.mkEnableOption "Tailscale Services for OCI containers";
    settings = {
      version = lib.mkOption {
        type = lib.types.str;
        description = "The Service configuration file format version.";
        default = "0.0.1";
      };
      services = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              endpoints = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                description = "Contains one or more endpoint mappings for incoming traffic to local resources.";
                default = { };
              };
              advertised = lib.mkOption {
                type = lib.types.bool;
                description = "Whether the service can accept new connections.";
                default = true;
              };
            };
          }
        );
        description =
          "The root object that contains one or more Services. "
          + "Service names must use the format svc:<service-name>. "
          + "Each key is a service name, and each value is a service configuration object, which contains one or more endpoint mappings.";
        default = { };
      };
    };
  };

  config = lib.mkIf config.services.tailscale.services.enable {
    services.tailscale.services.settings.services =
      lib.mkIf config.services.tailscale.services.enableContainers (
        lib.attrsets.mapAttrs' containerToService (
          lib.attrsets.filterAttrs notEmptyPorts config.virtualisation.oci-containers.containers
        )
      );

    # system.activationScripts.tailscale-serve-services =
    #   let
    #     configFile = pkgs.writeText "tailscale-service-config.json" (
    #       builtins.toJSON config.services.tailscale.services.settings
    #     );
    #   in
    #   ''
    #     ${lib.getExe pkgs.tailscale} serve set-config --all ${configFile}
    #   '';

    system.activationScripts.tailscale-serve-service-containers = builtins.concatStringsSep "\n" (
      [ "${lib.getExe pkgs.tailscale} serve reset" ]
      ++ lib.attrsets.mapAttrsToList containerToServe (
        lib.attrsets.filterAttrs notEmptyPorts config.virtualisation.oci-containers.containers
      )
    );
  };
}
