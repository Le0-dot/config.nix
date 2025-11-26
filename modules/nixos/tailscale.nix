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
    # TODO: Autopopulate for containers when enableContainers is true
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
