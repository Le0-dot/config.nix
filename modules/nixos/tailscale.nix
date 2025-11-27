{
  lib,
  pkgs,
  config,
  ...
}:

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
      lib.mkIf config.services.tailscale.services.enableContainers
        (
          let
            notEmptyPorts = _container: { ports, ... }: ports != [ ];
            containerToService =
              container:
              { ports, ... }:
              let
                getHostPort = port: builtins.head (builtins.split ":" port); # Assume format is "hostPort:containerPort"
                hostPort = getHostPort (builtins.head ports); # Publish only first port
              in
              lib.attrsets.nameValuePair "svc:${container}" {
                endpoints."tcp:443" = "http://localhost:${hostPort}";
              };
          in
          lib.attrsets.mapAttrs' containerToService (
            lib.attrsets.filterAttrs notEmptyPorts config.virtualisation.oci-containers.containers
          )
        );

    system.activationScripts.tailscale-services =
      let
        configFile = pkgs.writeText "tailscale-services.json" (
          builtins.toJSON config.services.tailscale.services.settings
        );
      in
      ''
        ${lib.getExe pkgs.tailscale} serve set-config --all ${configFile}
      '';
  };
}
