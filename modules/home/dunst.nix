{ lib, config, ... }:

{
  config = lib.mkIf config.services.dunst.enable {
    stylix.targets.dunst.enable = true;

    services.dunst.settings.global = {
      width = 300;
      height = 300;
      offset = "20x50";
      gap_size = 3;
      corner_radius = 10;
      follow = "keyboard";
      markup = "full";
      enable_recursive_icon_lookup = true;
    };
  };
}
