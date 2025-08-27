{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.wireplumber = lib.mkEnableOption "wireplumber";

  config.keybind.binds = lib.mkIf config.features.desktop.wireplumber [
    {
      key = "XF86AudioMute";
      action = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    }
    {
      key = "XF86AudioLowerVolume";
      action = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      type = "HOLD";
    }
    {
      key = "XF86AudioRaiseVolume";
      action = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      type = "HOLD";
    }
  ];
}
