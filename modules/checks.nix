{ inputs, lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    lib.optionalAttrs (system == "x86_64-linux") {
      checks.hm-systemmanager =
        let
          cfg = inputs.self.systemConfigs.omega.config;
        in
        # home-manager user config must exist under omega
        lib.throwIfNot (cfg.home-manager.users ? "lev.koliadich")
          "omega: home-manager user lev.koliadich not configured"
          # home-manager systemd service must be registered
          (lib.throwIfNot (cfg.systemd.services ? "home-manager-lev.koliadich")
            "omega: home-manager-lev.koliadich.service not in systemd"
            # OS user account must NOT be activated (external user on system-manager)
            (lib.throwIf cfg.users.users."lev.koliadich".enable
              "omega: users.users.lev.koliadich.enable must be false (no OS account)"
              (pkgs.runCommand "check-hm-systemmanager" { } "touch $out")));
    };
}
