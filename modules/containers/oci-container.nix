{ den, lib, ... }:
{
  den.classes.oci-container.description = "Container resources forwarded to the host's virtualisation.oci-containers.containers";

  den.policies.oci-container-to-host =
    { container, host, ... }:
    lib.optional (container.class == "oci-container") (
      den.lib.policy.route {
        fromClass = "oci-container";
        intoClass = host.class;
        path = [
          "virtualisation"
          "oci-containers"
          "containers"
        ];
        adaptArgs =
          args:
          args
          // { osConfig = args.config; } (name: args.config.virtualisation.oci-containers.containers.${name});
      }
    );

  den.schema.container.includes = [ den.policies.oci-container-to-host ];
}
