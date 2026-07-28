{
  den.aspects.desktop.hyprlock = {
    systemManager = { pkgs, ... }: {
      environment.etc."pam.d/hyprlock".text = ''
        auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so max_tries=3
        auth sufficient ${pkgs.sssd}/lib/security/pam_sss.so try_first_pass
        auth required ${pkgs.linux-pam}/lib/security/pam_deny.so
      '';
    };

    homeManger =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        stylix.targets.hyprlock.enable = true;
        programs.hyprlock = {
          enable = true;
          package = pkgs.writeShellApplication {
            name = "hyprlock";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.hyprlock
            ];
            text = "env LD_PRELOAD=${pkgs.sssd}/lib/libnss_sss.so.2 hyprlock $@";
          };
          settings = {
            general.hide_cursor = true;
            auth.fingerprint.enabled = true;
            background = lib.mkForce [
              {
                monitor = "";
                path = "screenshot";
                blur_passes = 3;
                blur_size = 3;
              }
            ];
            input-field = {
              monitor = "";
              size = "300, 60";
              halign = "center";
              valign = "center";
              outline_thickness = 4;
              dots_size = 0.33;
              dots_spacing = 0.2;
              dots_center = true;
              fade_on_empty = false;
              placeholder_text = "";
              hide_input = false;
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            };
          };
        };

        systemd.user.services.session-lock = {
          Unit = {
            Description = "Session lock target";
            Requires = [ "graphical-session.target" ];
            Wants = [ "on-session-lock.target" ];
            OnSuccess = [ "on-session-unlock.target" ];
          };
          Service = {
            ExecStart = lib.getExe config.programs.hyprlock.package;
          };
        };
      };
  };
}
