{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.services.hypridle.enable {
    services.hypridle.settings = {
      general = {
        lock_cmd = "pidof ${config.wm.lock} || ${config.wm.lock}";
        on_lock_cmd = "${pkgs.writeShellScript "on-lock" (
          builtins.concatStringsSep "\n" config.wm.on-lock
        )}";
        on_unlock_cmd = "${pkgs.writeShellScript "on-unlock" (
          builtins.concatStringsSep "\n" config.wm.on-unlock
        )}";
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
}
