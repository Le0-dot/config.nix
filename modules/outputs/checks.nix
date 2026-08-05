{ inputs, lib, ... }:
let
  nu = inputs.self.nixosConfigurations.nu.config;
  tau = inputs.self.nixosConfigurations.tau.config;
  omega = inputs.self.systemConfigs.omega.config;
in
{
  flake.checks.x86_64-linux = {
    build-nu = nu.system.build.toplevel;
    build-tau = tau.system.build.toplevel;
    build-omega = omega.build.toplevel;

  };

  perSystem =
    { pkgs, ... }:
    {
      checks = {
        assert-home-manager-and-system-manager-integration =
          lib.throwIfNot (omega.home-manager.users ? "lev.koliadich")
            "omega: home-manager user lev.koliadich not configured"
            (
              lib.throwIfNot (omega.systemd.services ? "home-manager-lev.koliadich")
                "omega: home-manager-lev.koliadich.service not in systemd"
                (
                  lib.throwIf omega.users.users."lev.koliadich".enable
                    "omega: users.users.''\"lev.koliadich''\".enable must be false (no OS account)"
                    (pkgs.runCommand "run-assert-home-manager-and-system-manager-integration" { } "touch $out")
                )
            );
      };
    };
}
