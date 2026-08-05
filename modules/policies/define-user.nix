{ den, lib, ... }:
{
  den.policies.system-manager-define-user =
    { host, user, ... }:
    den.lib.policy.include {
      systemManager.users.users.${user.name} = {
        enable = lib.mkDefault false;
        isNormalUser = true;
      };
    };

  den.default.includes = [
    den.batteries.define-user
    den.policies.system-manager-define-user
  ];
}
