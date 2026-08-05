{ den, lib, ... }:
{
  den.policies.system-manager-users-defaults =
    { host, user, ... }:
    den.lib.policy.include {
      systemManager.users.users.${user.name} = {
        enable = lib.mkDefault false;
        isNormalUser = lib.mkDefault true;
      };
    };

  den.schema.host.includes = [ den.policies.system-manager-users-defaults ];
}
