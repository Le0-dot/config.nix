{ pkgs, ... }:

{
  home.packages = [ pkgs.wireplumber ];

  keybind.binds = [
    {
      key = "XF86AudioMute";
      action = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    }
    {
      key = "XF86AudioLowerVolume";
      action = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      type = "HOLD";
    }
    {
      key = "XF86AudioRaiseVolume";
      action = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      type = "HOLD";
    }
  ];
}
