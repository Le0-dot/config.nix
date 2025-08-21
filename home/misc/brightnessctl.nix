{ pkgs, ... }:

{
  home.packages = [ pkgs.brightnessctl ];

  keybinds = [
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
}
