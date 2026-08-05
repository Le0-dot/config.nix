{ den, self, ... }:
{
  den.aspects.omega = {
    excludes = [ den.batteries.hostname ];
    systemManager = {
      nixpkgs.config.allowUnfree = true;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
      };
      systemd.tmpfiles.rules = [
        "d /etc/profiles 0755 root root -"
        "d /etc/profiles/per-user 0755 root root -"
      ];
    };
    checks =
      { lib, pkgs, ... }:
      let
        config = self.systemConfigs.omega.config;
      in
      {
        assert-omega-build = config.build.toplevel;
        assert-omega-users =
          lib.throwIfNot (config.home-manager.users ? "lev.koliadich")
            "omega: home-manager user lev.koliadich not configured"
            (
              lib.throwIfNot (config.systemd.services ? "home-manager-lev.koliadich")
                "omega: home-manager-lev.koliadich.service not in systemd"
                (
                  lib.throwIf config.users.users."lev.koliadich".enable
                    "omega: users.users.''\"lev.koliadich''\".enable must be false (no OS account)"
                    (pkgs.runCommand "run-assert-omega-users" { } "touch $out")
                )
            );
      };
  };
}
