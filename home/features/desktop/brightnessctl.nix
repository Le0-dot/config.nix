{ pkgs, ... }:

{
  keybind.binds = [
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
