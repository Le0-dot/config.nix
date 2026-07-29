{ den, ... }:
{
  den.aspects.desktop = {
    includes = [
      den.aspects.desktop.uwsm
      den.aspects.desktop.kanshi
      den.aspects.desktop.hypridle
      den.aspects.desktop.hyprlock
      den.aspects.desktop.hyprpaper
      den.aspects.desktop.dunst
      den.aspects.desktop.ghostty
      den.aspects.desktop.tofi
      den.aspects.desktop.waybar
      den.aspects.desktop.wlogout
    ];

    homeManager = { pkgs, ... }: {
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      home.packages = [ pkgs.brightnessctl ];

      programs.hyprshot.enable = true;
      services.hyprpolkitagent.enable = true;
      services.pipewire = {
        enable = true;
        wireplumber.enable = true;
      };

      stylix.targets.hyprland.enable = true;
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        extraLuaFiles.hyprland.content = ./hyprland.lua;
      };
    };
  };
}
