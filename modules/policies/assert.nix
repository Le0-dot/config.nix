{ den, self, ... }:
{
  den.aspects.assert-nixos-build =
    { host, ... }:
    {
      checks = {
        "assert-${host.hostName}-build" =
          self.nixosConfigurations.${host.name}.config.system.build.toplevel;
      };
    };

  den.aspects.assert-system-manager-build =
    { host, ... }:
    {
      checks = {
        "assert-${host.hostName}-build" = self.systemConfigs.${host.name}.config.build.toplevel;
      };
    };

  den.policies.assert-build =
    { host, ... }:
    let
      class-aspects = {
        nixos = den.aspects.assert-nixos-build;
        systemManager = den.aspects.assert-system-manager-build;
      };
    in
    den.lib.policy.include (class-aspects.${host.class} or { });

  den.schema.host.includes = [ den.policies.assert-build ];
}
