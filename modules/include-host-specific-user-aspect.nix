{ den, ... }:
{
  den.policies.include-host-specific-user-aspect =
    { host, user, ... }:
    den.lib.policy.include (den.aspects."${user.userName}@${host.hostName}" or { });

  den.schema.user.includes = [ den.policies.include-host-specific-user-aspect ];
}
