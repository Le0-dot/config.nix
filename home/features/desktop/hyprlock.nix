{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.features.desktop.hyprlock = lib.mkEnableOption "hyprlock";

  config = lib.mkIf config.features.desktop.hyprlock {
    stylix.targets.hyprlock.enable = true;

    programs.hyprlock = {
      enable = true;
      package = pkgs.writeShellScriptBin "hyprlock" ''
        export LD_PRELOAD="${pkgs.sssd}/lib/libnss_sss.so.2:$LD_PRELOAD"
        exec ${pkgs.hyprlock}/bin/hyprlock "$@"
      '';
      settings = {
        general = {
          hide_cursor = true;
        };

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

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          on_lock_cmd = "playerctl-save && playerctl -a pause";
          on_unlock_cmd = "playerctl-resume";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 600;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
