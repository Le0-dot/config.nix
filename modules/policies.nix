{ den, lib, ... }:
{
  den.policies.include-username-aspect =
    { home, ... }:
    lib.optional (den.aspects ? ${home.userName}) (den.lib.policy.include den.aspects.${home.userName});
}
