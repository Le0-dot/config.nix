{
  den,
  lib,
  inputs,
  ...
}:
let
  inherit (import "${inputs.den}/nix/lib/entities/_types.nix" { inherit lib den; }) lookupAspectBy;
in
{
  den.schema.container = {
    inherits = [ den.schema.conf ];
    parent = "host";
  };

  den.policies.host-to-containers =
    { host, ... }:
    map (container: den.lib.policy.resolve.shared { inherit container; }) (
      lib.attrValues host.containers
    );

  den.schema.host =
    { host, ... }:
    {
      options.containers = lib.mkOption {
        description = "Containers that run on this host.";
        default = { };
        type = lib.types.attrsOf (
          den.lib.schema.mkInstanceType {
            extraModules = [
              (
                { config, ... }:
                {
                  config._module.args.host = host;
                  options = {
                    class = lib.mkOption {
                      description = "Container runtime this container is deployed with.";
                      type = lib.types.enum [ "quadlet" ];
                      example = "quadlet";
                    };
                    containerName = lib.mkOption {
                      description = "Container name";
                      type = lib.types.str;
                      default = config.name;
                    };
                    description = lib.mkOption {
                      description = "Container description";
                      type = lib.types.str;
                      default = "${config.class}.${config.containerName}@${host.name}";
                    };
                    aspect = lib.mkOption {
                      description = ''
                        Aspect that configures this container. Both den.aspects.<name>@<host>
                        and den.aspects.<name> apply where they exist.
                      '';
                      type = lib.types.raw;
                      defaultText = "den.aspects.<name>@<host> and den.aspects.<name>";
                      default = lookupAspectBy den [
                        "${config.name}@${host.name}"
                        config.name
                      ];
                    };
                    host = lib.mkOption {
                      description = "The host this container runs on.";
                      default = host;
                      defaultText = lib.literalExpression "host";
                    };
                  };
                }
              )
            ];
          } den.schema.container
        );
      };
      config.includes = [ den.policies.host-to-containers ];
    };
}
