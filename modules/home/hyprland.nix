{
  pkgs,
  lib,
  config,
  perSystem,
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

    home.packages = [
      pkgs.wireplumber
      pkgs.brightnessctl
      perSystem.self.choose-repo
      perSystem.self.clipselect
    ];

    programs.hyprshot.enable = true;

    wayland.windowManager.hyprland = {
      systemd.enable = false;
      extraLuaFiles = {
        config.content = ./config.lua;
        rules.content = ./rules.lua;
        binds.content = ./binds.lua;
      };
    };
  };
}
