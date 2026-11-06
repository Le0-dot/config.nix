{
  den,
  lib,
  inputs,
  ...
}:
{
  den.classes.quadlet.description = "Quadlet resources of a container forwarding to the host's virtualisation.quadlet";

  den.policies.quadlet-to-host =
    { container, host, ... }:
    lib.optional (host.quadlet.enable && container.class == "quadlet") (
      den.lib.policy.route {
        fromClass = "quadlet";
        intoClass = host.class;
        path = [
          "virtualisation"
          "quadlet"
        ];
        adaptArgs =
          args:
          args
          // lib.genAttrs [
            "builds"
            "containers"
            "images"
            "kubes"
            "networks"
            "pods"
            "volumes"
          ] (name: args.config.virtualisation.quadlet.${name});
      }
    );

  den.schema.container.includes = [ den.policies.quadlet-to-host ];

  den.policies.quadlet-module =
    { host, ... }:
    lib.optional host.quadlet.enable (
      den.lib.policy.provide {
        class = host.class;
        module = {
          key = "den:quadlet-host-module";
          imports = [ host.quadlet.module ];
        };
      }
    );

  den.schema.host = { host, ... }: {
    options.quadlet = {
      enable = lib.mkOption {
        description = "Whether to enable quadlet on this host.";
        type = lib.types.bool;
        defaultText = lib.literalExpression ''any container of the host has class "quadlet"'';
        default = lib.any (container: container.class == "quadlet") (lib.attrValues host.containers);
      };
      module = lib.mkOption {
        description = "quadlet-nix module to import on this host.";
        type = lib.types.deferredModule;
        defaultText = lib.literalExpression "inputs.quadlet-nix.nixosModules.quadlet";
        default = inputs.quadlet-nix.nixosModules.quadlet;
      };
    };
    config.includes = [ den.policies.quadlet-module ];
  };
}
