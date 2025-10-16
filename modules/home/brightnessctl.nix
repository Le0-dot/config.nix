{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.programs.brightnessctl.enable = lib.mkEnableOption "brightnessctl";

  config = lib.mkIf config.programs.brightnessctl.enable {
    home.packages = [ pkgs.brightnessctl ];

    keybind.binds = [
      {
        key = "XF86MonBrightnessDown";
        action = "brightnessctl set 5%-";
        type = "HOLD";
      }
      {
        key = "XF86MonBrightnessUp";
        action = "brightnessctl set 5%+";
        type = "HOLD";
      }
    ];
  };
}
