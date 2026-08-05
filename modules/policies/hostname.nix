{ den, lib, ... }:
{
  den.policies.include-hostname =
    { host, ... }:
    den.lib.policy.include (lib.optional (host.class != "systemManager") den.batteries.hostname);

  den.schema.host.includes = [ den.policies.include-hostname ];
}
