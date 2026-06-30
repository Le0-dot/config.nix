{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    stylix.targets.hyprland.enable = true;
    keybind.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      systemd.enable = false;
      extraLuaFiles = {
        config.content = builtins.readFile ./config.lua;
        rules.content = builtins.readFile ./rules.lua;
        binds.content = builtins.readFile ./binds.lua;
      };
    };
  };
}
