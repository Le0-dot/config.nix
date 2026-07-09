{ den, lib, ... }:

{
  den.schema.home = { name, config, ... }: {
    name = lib.mkOverride 30 name; # make user@host1 != user@host2
    aspect = den.aspects.${config.userName};
  };

  den.default.includes = [
    den.batteries.define-user
    (
      { home }:
      lib.optional (den.aspects ? ${home.name}) (den.lib.policy.include den.aspects.${home.name})
    )
  ];
}
