{ den, lib, ... }:
let
  inherit (den.lib.policy) include;
in
{
  den.policies = {
    include-username-aspect =
      { home, ... }:
      lib.optional (den.aspects ? ${home.userName}) (include den.aspects.${home.userName});
    home-to-host =
      { host, ... }:
      let
        allHomes = lib.concatMap builtins.attrValues (builtins.attrValues den.homes);
      in
      lib.concatMap (
        home:
        lib.optional (home.hostName == host.name) (include [
          den.aspects.${home.userName}
          den.aspects."${home.userName}@${home.hostName}"
        ])
      ) allHomes;
  };
}
