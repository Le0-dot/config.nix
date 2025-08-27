{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.brightnessctl = lib.mkEnableOption "brightnessctl";

  config.keybins.binds = lib.mkIf config.features.desktop.brightnessctl [
    {
      key = "XF86MonBrightnessDown";
      action = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      type = "HOLD";
    }
    {
      key = "XF86MonBrightnessUp";
      action = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
      type = "HOLD";
    }
  ];
}
