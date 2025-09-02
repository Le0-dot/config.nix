{ lib, config, ... }:

{
  options.features.desktop.dunst = lib.mkEnableOption "dunst";

  config = lib.mkIf config.features.desktop.dunst {
    stylix.targets.dunst.enable = true;

    services.dunst = {
      enable = true;
      settings.global = {
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
  };
}
