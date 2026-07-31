{ den, lib, ... }:
{
  den.policies = {
    system-manager-users-defaults =
      { host, ... }:
      den.lib.policy.include {
        systemManager.users.users = lib.mapAttrs (name: _: {
          enable = lib.mkDefault false;
          isNormalUser = lib.mkDefault true;
        }) host.users;
      };
    host-specific-user-aspect =
      { host, user, ... }:
      let
        aspect = "${user.name}@${host.name}";
      in
      lib.optional (den.aspects ? aspect) (den.lib.policy.include den.aspects.${aspect});
  };
}
