{ den, lib, ... }:
{
  den.policies = {
    host-specific-user-aspect =
      { host, user, ... }:
      den.lib.policy.include (den.aspects."${user.name}@${host.name}" or { });
  };
}
