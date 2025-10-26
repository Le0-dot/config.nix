{
  pkgs,
  lib,
  config,
  perSystem,
  ...
}:

{
  config = lib.mkIf config.programs.hyprlock.enable {
    stylix.targets.hyprlock.enable = true;

    programs.hyprlock = {
      package = perSystem.self.hyprlock;
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
}
